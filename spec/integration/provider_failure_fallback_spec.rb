# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe "Provider failure fallback flow", type: :request do
  let(:provider_client) { instance_double(CoinGeckoClient) }
  let(:repository) { CryptoPriceRepository.new }
  let(:cache) { PriceCache.new }
  let(:refresh_service) do
    PriceRefreshService.new(
      provider_client: provider_client,
      repository: repository,
      cache: cache
    )
  end

  before do
    Rails.cache.clear
  end

  it "preserves and serves the last known price after provider refresh failure" do
    existing_price = create(
      :crypto_price,
      symbol: "BTC",
      price: BigDecimal("50000.00"),
      currency: "USD",
      provider: "coingecko",
      fetched_at: Time.zone.parse("2026-07-08 10:00:00 UTC")
    )
    allow(provider_client).to receive(:fetch_price)
      .with(symbol: "BTC", currency: "USD")
      .and_raise(ProviderError::TimeoutError, "CoinGecko request timed out")

    refresh_result = refresh_service.refresh(symbol: "BTC", currency: "USD")
    get "/prices/btc"

    expect(refresh_result).to be_failure
    expect(refresh_result.error).to be_a(ProviderError::TimeoutError)
    expect(existing_price.reload).to have_attributes(
      price: BigDecimal("50000.00"),
      fetched_at: Time.zone.parse("2026-07-08 10:00:00 UTC")
    )
    expect(CryptoPrice.where(symbol: "BTC", currency: "USD", provider: "coingecko").count).to eq(1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "symbol" => "btc",
      "price" => 50_000.0,
      "currency" => "usd",
      "last_updated_at" => "2026-07-08T10:00:00Z"
    )
  end
end
# rubocop:enable Metrics/BlockLength
