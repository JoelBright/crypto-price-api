class PricesController < ApplicationController
  rescue_from StandardError, with: :render_internal_error

  DEFAULT_CURRENCY = "USD".freeze
  PROVIDER = CoinGeckoClient::PROVIDER
  SYMBOL_FORMAT = /\A[a-zA-Z]{2,10}\z/

  def show
    normalized_symbol = normalize_symbol(params[:symbol])

    return render_error(:invalid_symbol, :bad_request) if invalid_symbol?(normalized_symbol)
    return render_unsupported_symbol(normalized_symbol) unless supported_symbol?(normalized_symbol)

    render_query_result(query_price(normalized_symbol), normalized_symbol)
  end

  private

  def query_price(symbol)
    price_query_service.query(symbol: symbol, currency: DEFAULT_CURRENCY, provider: PROVIDER)
  end

  def price_query_service
    @price_query_service ||= PriceQueryService.new(
      repository: CryptoPriceRepository.new,
      cache: PriceCache.new
    )
  end

  def normalize_symbol(symbol)
    symbol.to_s.strip.upcase
  end

  def invalid_symbol?(symbol)
    !valid_symbol_format?(symbol)
  end

  def valid_symbol_format?(symbol)
    SYMBOL_FORMAT.match?(symbol)
  end

  def supported_symbol?(symbol)
    CoinGeckoClient::SYMBOL_MAPPING.key?(symbol)
  end

  def render_query_result(result, symbol)
    if result.found?
      render json: PriceResponseSerializer.new(result.price_record).as_json, status: :ok
    else
      render_error(:price_not_found, :not_found, public_symbol(symbol))
    end
  end

  def render_unsupported_symbol(symbol)
    render_error(:unsupported_symbol, :unprocessable_content, public_symbol(symbol))
  end

  def public_symbol(symbol)
    symbol.downcase
  end

  def render_internal_error(error)
    Rails.logger.error(
      message: "Unexpected price API failure",
      error: error.class.name,
      symbol: params[:symbol].to_s
    )
    render_error(:internal_error, :internal_server_error)
  end

  def render_error(code, status, symbol = nil)
    render json: ErrorResponseSerializer.new(code: code, symbol: symbol).as_json, status: status
  end
end
