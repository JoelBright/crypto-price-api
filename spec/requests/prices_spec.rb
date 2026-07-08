# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe "Prices API", type: :request do
  before do
    Rails.cache.clear
  end

  describe "GET /prices/:symbol" do
    let(:fetched_at) { Time.zone.parse("2026-07-08 12:34:56 UTC") }

    it "returns a successful price response for a supported symbol" do
      create(
        :crypto_price,
        symbol: "BTC",
        price: BigDecimal("109283.12"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: fetched_at
      )

      get "/prices/btc"

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("application/json")
      expect(json_response).to eq(
        "symbol" => "btc",
        "price" => 109_283.12,
        "currency" => "usd",
        "last_updated_at" => "2026-07-08T12:34:56Z"
      )
    end

    it "normalizes uppercase request symbols to lowercase API responses" do
      create(
        :crypto_price,
        symbol: "BTC",
        price: BigDecimal("50123.45"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: fetched_at
      )

      get "/prices/BTC"

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        "symbol" => "btc",
        "currency" => "usd"
      )
    end

    it "returns invalid_symbol for malformed symbols" do
      get "/prices/btc-usd"

      expect(response).to have_http_status(:bad_request)
      expect(json_response).to eq(
        "error" => {
          "code" => "invalid_symbol",
          "message" => "The symbol must contain only letters and be between 2 and 10 characters long."
        }
      )
    end

    it "returns unsupported_symbol for syntactically valid unsupported symbols" do
      get "/prices/doge"

      expect(response).to have_http_status(:unprocessable_content)
      expect(json_response).to eq(
        "error" => {
          "code" => "unsupported_symbol",
          "message" => "The symbol 'doge' is not supported by this API."
        }
      )
    end

    it "returns price_not_found for a supported symbol without stored data" do
      get "/prices/eth"

      expect(response).to have_http_status(:not_found)
      expect(json_response).to eq(
        "error" => {
          "code" => "price_not_found",
          "message" => "No stored price is available for symbol 'eth'."
        }
      )
    end

    it "returns persisted data when cache is empty" do
      create(
        :crypto_price,
        symbol: "ETH",
        price: BigDecimal("3100.99"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: fetched_at
      )

      get "/prices/eth"

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        "symbol" => "eth",
        "price" => 3100.99,
        "currency" => "usd",
        "last_updated_at" => "2026-07-08T12:34:56Z"
      )
    end

    it "serializes cached service payloads when available" do
      service = instance_double(PriceQueryService)
      result = PriceQueryService::Result.new(
        found: true,
        price_record: {
          symbol: "BTC",
          price: BigDecimal("60000.50"),
          currency: "USD",
          provider: "coingecko",
          fetched_at: fetched_at
        }
      )

      allow(PriceQueryService).to receive(:new).and_return(service)
      allow(service).to receive(:query).and_return(result)

      get "/prices/btc"

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(
        "symbol" => "btc",
        "price" => 60_000.50,
        "currency" => "usd",
        "last_updated_at" => "2026-07-08T12:34:56Z"
      )
    end

    it "uses a consistent error envelope for API failures" do
      get "/prices/eth"

      expect(json_response.keys).to contain_exactly("error")
      expect(json_response.fetch("error").keys).to contain_exactly("code", "message")
    end

    it "delegates supported valid requests to the query service" do
      service = instance_double(PriceQueryService)
      result = PriceQueryService::Result.new(
        found: true,
        price_record: {
          symbol: "BTC",
          price: BigDecimal("45000.25"),
          currency: "USD",
          provider: "coingecko",
          fetched_at: fetched_at
        }
      )

      allow(PriceQueryService).to receive(:new).and_return(service)
      allow(service).to receive(:query).and_return(result)

      get "/prices/btc"

      expect(service).to have_received(:query).with(
        symbol: "BTC",
        currency: "USD",
        provider: "coingecko"
      )
      expect(response).to have_http_status(:ok)
    end

    it "returns a safe internal_error envelope for unexpected failures" do
      service = instance_double(PriceQueryService)
      allow(PriceQueryService).to receive(:new).and_return(service)
      allow(service).to receive(:query).and_raise(StandardError, "database password leaked")

      get "/prices/btc"

      expect(response).to have_http_status(:internal_server_error)
      expect(json_response).to eq(
        "error" => {
          "code" => "internal_error",
          "message" => "An unexpected error occurred while processing the request."
        }
      )
      expect(response.body).not_to include("database password leaked")
    end
  end

  def json_response
    response.parsed_body
  end
end
# rubocop:enable Metrics/BlockLength
