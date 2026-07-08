require "rails_helper"

# rubocop:disable Metrics/BlockLength, Rails/SkipsModelValidations
RSpec.describe CryptoPriceRepository do
  subject(:repository) { described_class.new }

  describe "#find" do
    it "looks up a price by normalized symbol, currency, and provider" do
      price = create(:crypto_price, symbol: "BTC", currency: "USD", provider: "coingecko")

      result = repository.find(symbol: " btc ", currency: " usd ", provider: "CoinGecko")

      expect(result).to eq(price)
    end

    it "returns nil when no matching price exists" do
      expect(repository.find(symbol: "ETH", currency: "USD", provider: "coingecko")).to be_nil
    end

    it "does not match only by symbol" do
      create(:crypto_price, symbol: "BTC", currency: "EUR", provider: "coingecko")
      create(:crypto_price, symbol: "BTC", currency: "USD", provider: "other")

      result = repository.find(symbol: "BTC", currency: "USD", provider: "coingecko")

      expect(result).to be_nil
    end
  end

  describe "#upsert" do
    it "creates a current price record when none exists" do
      fetched_at = Time.zone.parse("2026-07-08 12:00:00 UTC")

      result = repository.upsert(
        symbol: " btc ",
        price: BigDecimal("12345.6789"),
        currency: " usd ",
        provider: "CoinGecko",
        fetched_at: fetched_at
      )

      expect(result).to be_persisted
      expect(result).to have_attributes(
        symbol: "BTC",
        price: BigDecimal("12345.6789"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: fetched_at
      )
    end

    it "updates the existing current price record" do
      existing = create(
        :crypto_price,
        symbol: "BTC",
        price: BigDecimal("100.00"),
        currency: "USD",
        provider: "coingecko",
        fetched_at: Time.zone.parse("2026-07-08 10:00:00 UTC")
      )
      fetched_at = Time.zone.parse("2026-07-08 12:00:00 UTC")

      result = repository.upsert(
        symbol: "btc",
        price: BigDecimal("125.50"),
        currency: "usd",
        provider: "CoinGecko",
        fetched_at: fetched_at
      )

      expect(result.id).to eq(existing.id)
      expect(result.reload).to have_attributes(
        price: BigDecimal("125.50"),
        fetched_at: fetched_at
      )
    end

    it "prevents duplicate current records for the same symbol, currency, and provider" do
      fetched_at = Time.zone.parse("2026-07-08 12:00:00 UTC")

      repository.upsert(symbol: "btc", price: 100, currency: "usd", provider: "coingecko", fetched_at: fetched_at)
      repository.upsert(symbol: "BTC", price: 101, currency: "USD", provider: "CoinGecko", fetched_at: fetched_at)

      expect(CryptoPrice.where(symbol: "BTC", currency: "USD", provider: "coingecko").count).to eq(1)
    end

    it "does not call cache, external APIs, retries, or logging" do
      expect(Rails.cache).not_to receive(:read)
      expect(Rails.cache).not_to receive(:write)
      expect(Rails.cache).not_to receive(:delete)
      expect(Rails.logger).not_to receive(:info)
      expect(Rails.logger).not_to receive(:error)

      repository.upsert(
        symbol: "btc",
        price: 100,
        currency: "usd",
        provider: "coingecko",
        fetched_at: Time.zone.parse("2026-07-08 12:00:00 UTC")
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength, Rails/SkipsModelValidations
