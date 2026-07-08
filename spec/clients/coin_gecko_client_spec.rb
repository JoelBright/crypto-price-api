require "rails_helper"
require "faraday"

# rubocop:disable Metrics/BlockLength
RSpec.describe CoinGeckoClient do
  let(:api_key) { "test-secret-api-key" }
  let(:logger) { instance_spy(ActiveSupport::Logger) }

  def response(status:, body:)
    instance_double(Faraday::Response, status: status, body: body)
  end

  def connection_for(response_or_error)
    connection = instance_double(Faraday::Connection)

    if response_or_error.is_a?(Array)
      allow(connection).to receive(:get).and_return(*response_or_error)
    elsif response_or_error.is_a?(Exception)
      allow(connection).to receive(:get).and_raise(response_or_error)
    else
      allow(connection).to receive(:get).and_return(response_or_error)
    end

    connection
  end

  describe "#fetch_price" do
    it "parses a successful response into normalized application-level data" do
      body = file_fixture("coingecko/simple_price_success.json").read
      connection = connection_for(response(status: 200, body: body))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      result = client.fetch_price(symbol: "BTC", currency: "usd")

      expect(result).to include(
        symbol: "BTC",
        price: BigDecimal("109283.12"),
        currency: "USD",
        provider: "coingecko"
      )
      expect(result.fetch(:fetched_at)).to be_a(Time)
      expect(connection).to have_received(:get).with(
        "/api/v3/simple/price",
        hash_including(ids: "bitcoin", vs_currencies: "usd")
      )
    end

    it "rejects unsupported symbols before making a provider request" do
      connection = instance_double(Faraday::Connection, get: nil)
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "DOGE") }.to raise_error(ProviderError::UnsupportedSymbolError) do |error|
        expect(error.message).to include("DOGE")
      end
      expect(connection).not_to have_received(:get)
    end

    it "raises a configuration error when the API key is missing" do
      connection = instance_double(Faraday::Connection, get: nil)
      client = described_class.new(api_key: "  ", connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::ConfigurationError)
      expect(connection).not_to have_received(:get)
    end

    it "translates unsuccessful HTTP responses" do
      connection = connection_for(response(status: 429, body: '{"status":{"error_message":"rate limit"}}'))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::HttpError) do |error|
        expect(error.message).to include("429")
        expect(error.message).not_to include(api_key)
      end
    end

    it "translates timeout failures" do
      connection = connection_for(Faraday::TimeoutError.new("execution expired #{api_key}"))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::TimeoutError) do |error|
        expect(error.message).not_to include(api_key)
      end
    end

    it "translates network failures" do
      connection = connection_for(Faraday::ConnectionFailed.new("network down #{api_key}"))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::NetworkError) do |error|
        expect(error.message).not_to include(api_key)
      end
    end

    it "translates invalid JSON responses" do
      connection = connection_for(response(status: 200, body: "not-json #{api_key}"))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::ParseError) do |error|
        expect(error.message).not_to include(api_key)
      end
    end

    it "rejects malformed non-object JSON responses" do
      connection = connection_for(response(status: 200, body: "[]"))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::MalformedResponseError)
    end

    it "rejects responses missing the expected provider ID" do
      connection = connection_for(response(status: 200, body: '{"ethereum":{"usd":1}}'))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::MalformedResponseError)
    end

    it "rejects responses missing the expected currency" do
      connection = connection_for(response(status: 200, body: '{"bitcoin":{"eur":1}}'))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc", currency: "usd") }.to raise_error(ProviderError::MalformedResponseError)
    end

    it "rejects non-numeric prices" do
      connection = connection_for(response(status: 200, body: '{"bitcoin":{"usd":"not-a-number"}}'))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::MalformedResponseError)
    end

    it "rejects non-positive prices" do
      connection = connection_for(response(status: 200, body: '{"bitcoin":{"usd":0}}'))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::MalformedResponseError)
    end

    it "bounds retry attempts for retryable provider failures" do
      failed_response = response(status: 502, body: "bad gateway")
      successful_response = response(status: 200, body: file_fixture("coingecko/simple_price_success.json").read)
      connection = connection_for([failed_response, failed_response, successful_response])
      client = described_class.new(api_key: api_key, connection: connection, logger: logger, max_retries: 1)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::HttpError)
      expect(connection).to have_received(:get).twice
    end

    it "does not expose the API key in logs or raised errors" do
      connection = connection_for(response(status: 500, body: "provider failed #{api_key}"))
      client = described_class.new(api_key: api_key, connection: connection, logger: logger)

      expect { client.fetch_price(symbol: "btc") }.to raise_error(ProviderError::HttpError) do |error|
        expect(error.message).not_to include(api_key)
      end
      expect(logger).to have_received(:warn).at_least(:once) do |payload|
        expect(payload.to_s).not_to include(api_key)
      end
    end
  end

  describe ".build_connection" do
    it "configures the base URL, API key, and timeouts without logging secrets" do
      connection = described_class.build_connection(
        base_url: "https://example.test",
        api_key: api_key,
        request_timeout: 3,
        open_timeout: 1
      )

      expect(connection.url_prefix.to_s).to eq("https://example.test/")
      expect(connection.options.timeout).to eq(3)
      expect(connection.options.open_timeout).to eq(1)
      expect(connection.headers["x-cg-demo-api-key"]).to eq(api_key)
    end
  end
end
# rubocop:enable Metrics/BlockLength
