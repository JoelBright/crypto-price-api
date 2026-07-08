require "bigdecimal"
require "faraday"
require "json"

# rubocop:disable Metrics/ClassLength
class CoinGeckoClient
  PROVIDER = "coingecko".freeze
  DEFAULT_BASE_URL = "https://api.coingecko.com".freeze
  DEFAULT_REQUEST_TIMEOUT = 5
  DEFAULT_OPEN_TIMEOUT = 2
  DEFAULT_MAX_RETRIES = 1
  API_KEY_HEADER = "x-cg-demo-api-key".freeze
  SIMPLE_PRICE_PATH = "/api/v3/simple/price".freeze
  RETRYABLE_HTTP_STATUSES = [408, 429, 500, 502, 503, 504].freeze
  SYMBOL_MAPPING = {
    "BTC" => "bitcoin",
    "ETH" => "ethereum"
  }.freeze

  class << self
    def build_connection(base_url:, api_key:, request_timeout:, open_timeout:)
      Faraday.new(url: base_url) do |connection|
        connection.headers[API_KEY_HEADER] = api_key
        connection.options.timeout = request_timeout
        connection.options.open_timeout = open_timeout
        connection.adapter Faraday.default_adapter
      end
    end
  end

  def initialize( # rubocop:disable Metrics/ParameterLists
    api_key: ENV.fetch("COINGECKO_API_KEY", nil),
    base_url: ENV.fetch("COINGECKO_BASE_URL", DEFAULT_BASE_URL),
    request_timeout: ENV.fetch("COINGECKO_REQUEST_TIMEOUT", DEFAULT_REQUEST_TIMEOUT).to_i,
    open_timeout: ENV.fetch("COINGECKO_OPEN_TIMEOUT", DEFAULT_OPEN_TIMEOUT).to_i,
    max_retries: ENV.fetch("COINGECKO_MAX_RETRIES", DEFAULT_MAX_RETRIES).to_i,
    connection: nil,
    logger: Rails.logger
  )
    @api_key = api_key
    @base_url = base_url
    @request_timeout = request_timeout
    @open_timeout = open_timeout
    @max_retries = [max_retries, 0].max
    @connection = connection
    @logger = logger
  end

  def fetch_price(symbol:, currency: "usd")
    normalized_symbol = normalize_symbol(symbol)
    normalized_currency = normalize_currency(currency)
    provider_id = provider_id_for(normalized_symbol)

    ensure_configured!

    response = request_with_retries(provider_id: provider_id, currency: normalized_currency.downcase)
    parse_response(response.body, provider_id: provider_id, symbol: normalized_symbol, currency: normalized_currency)
  end

  private

  attr_reader :api_key, :base_url, :request_timeout, :open_timeout, :max_retries, :logger

  def connection
    @connection ||= self.class.build_connection(
      base_url: base_url,
      api_key: api_key,
      request_timeout: request_timeout,
      open_timeout: open_timeout
    )
  end

  def normalize_symbol(value)
    value.to_s.strip.upcase
  end

  def normalize_currency(value)
    value.to_s.strip.upcase
  end

  def provider_id_for(symbol)
    SYMBOL_MAPPING.fetch(symbol)
  rescue KeyError
    raise ProviderError::UnsupportedSymbolError, "Unsupported cryptocurrency symbol: #{symbol}"
  end

  def ensure_configured!
    return if api_key.to_s.strip.present?

    raise ProviderError::ConfigurationError, "CoinGecko API key is not configured"
  end

  def request_with_retries(provider_id:, currency:)
    attempts = 0

    loop do
      attempts += 1
      response = perform_request(provider_id: provider_id, currency: currency)
      return response if response.status.between?(200, 299)

      log_failure(status: response.status, attempt: attempts)
      raise_http_error(response.status) unless retryable_status?(response.status) && attempts <= max_retries
    end
  end

  def perform_request(provider_id:, currency:)
    connection.get(SIMPLE_PRICE_PATH, ids: provider_id, vs_currencies: currency)
  rescue Faraday::TimeoutError
    log_failure(status: "timeout")
    raise ProviderError::TimeoutError, "CoinGecko request timed out"
  rescue Faraday::ConnectionFailed
    log_failure(status: "network_failure")
    raise ProviderError::NetworkError, "CoinGecko network request failed"
  rescue Faraday::Error
    log_failure(status: "network_failure")
    raise ProviderError::NetworkError, "CoinGecko request failed"
  end

  def parse_response(body, provider_id:, symbol:, currency:)
    parsed = JSON.parse(body)
    validate_response!(parsed, provider_id: provider_id, currency: currency)

    price_payload(symbol: symbol, currency: currency, value: parsed.fetch(provider_id).fetch(currency.downcase))
  rescue JSON::ParserError
    raise ProviderError::ParseError, "CoinGecko response was not valid JSON"
  end

  def validate_response!(parsed, provider_id:, currency:)
    raise ProviderError::MalformedResponseError, "CoinGecko response must be a JSON object" unless parsed.is_a?(Hash)

    provider_payload = parsed[provider_id]
    unless provider_payload.is_a?(Hash)
      raise ProviderError::MalformedResponseError, "CoinGecko response missing expected provider ID"
    end

    unless provider_payload.key?(currency.downcase)
      raise ProviderError::MalformedResponseError, "CoinGecko response missing expected currency"
    end

    parse_price(provider_payload.fetch(currency.downcase))
  end

  def price_payload(symbol:, currency:, value:)
    {
      symbol: symbol,
      price: parse_price(value),
      currency: currency,
      provider: PROVIDER,
      fetched_at: Time.current
    }
  end

  def parse_price(value)
    price = BigDecimal(value.to_s)
    return price if price.positive?

    raise ProviderError::MalformedResponseError, "CoinGecko price must be greater than zero"
  rescue ArgumentError
    raise ProviderError::MalformedResponseError, "CoinGecko price must be numeric"
  end

  def retryable_status?(status)
    RETRYABLE_HTTP_STATUSES.include?(status)
  end

  def raise_http_error(status)
    raise ProviderError::HttpError, "CoinGecko request failed with HTTP status #{status}"
  end

  def log_failure(status:, attempt: nil)
    logger.warn(
      provider: PROVIDER,
      event: "provider_request_failed",
      status: status,
      attempt: attempt
    )
  end
end
# rubocop:enable Metrics/ClassLength
