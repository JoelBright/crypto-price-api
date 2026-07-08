# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe "Price refresh to API flow", type: :request do
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

  it "makes a refreshed provider price available through GET /prices/:symbol" do
    fetched_at = Time.zone.parse("2026-07-08 14:15:16 UTC")
    allow(provider_client).to receive(:fetch_price).with(symbol: "BTC", currency: "USD").and_return(
      symbol: "BTC",
      price: BigDecimal("61234.56"),
      currency: "USD",
      provider: "coingecko",
      fetched_at: fetched_at
    )

    refresh_result = refresh_service.refresh(symbol: "BTC", currency: "USD")
    get "/prices/btc"

    expect(refresh_result).to be_success
    expect(CryptoPrice.where(symbol: "BTC", currency: "USD", provider: "coingecko").count).to eq(1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq(
      "symbol" => "btc",
      "price" => 61_234.56,
      "currency" => "usd",
      "last_updated_at" => "2026-07-08T14:15:16Z"
    )
  end
end
# rubocop:enable Metrics/BlockLength
