require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe PriceCache do
  let(:cache_store) { ActiveSupport::Cache::MemoryStore.new }

  subject(:cache) { described_class.new(cache_store: cache_store) }

  describe "#key" do
    it "builds a stable key from symbol, currency, and provider" do
      expect(cache.key(symbol: "BTC", currency: "USD", provider: "coingecko")).to eq("prices:coingecko:BTC:USD")
    end

    it "normalizes key inputs" do
      expect(cache.key(symbol: " btc ", currency: " usd ", provider: "CoinGecko")).to eq("prices:coingecko:BTC:USD")
    end
  end

  describe "#read and #write" do
    it "writes and reads a simple price payload" do
      price = build_stubbed(
        :crypto_price,
        symbol: "btc",
        price: BigDecimal("12345.6789"),
        currency: "usd",
        provider: "CoinGecko",
        fetched_at: Time.zone.parse("2026-07-08 12:00:00 UTC")
      )

      cache.write(price)

      expect(cache.read(symbol: "BTC", currency: "USD", provider: "coingecko")).to eq(
        symbol: "BTC",
        price: BigDecimal("12345.6789"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: Time.zone.parse("2026-07-08 12:00:00 UTC")
      )
    end

    it "returns nil on a cache miss" do
      expect(cache.read(symbol: "BTC", currency: "USD", provider: "coingecko")).to be_nil
    end

    it "uses the injected cache store" do
      price = build_stubbed(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")

      cache.write(price)

      expect(cache_store.read("prices:coingecko:BTC:USD")).to include(symbol: "BTC")
    end
  end

  describe "#delete" do
    it "removes the cached price payload" do
      price = build_stubbed(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")
      cache.write(price)

      cache.delete(symbol: "BTC", currency: "USD", provider: "coingecko")

      expect(cache.read(symbol: "BTC", currency: "USD", provider: "coingecko")).to be_nil
    end
  end
end
# rubocop:enable Metrics/BlockLength
