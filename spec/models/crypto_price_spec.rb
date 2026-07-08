require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe CryptoPrice, type: :model do
  describe "factory" do
    it "has a valid factory" do
      expect(build(:crypto_price)).to be_valid
    end
  end

  describe "validations" do
    it "requires symbol" do
      record = build(:crypto_price, symbol: nil)
      expect(record).not_to be_valid
      expect(record.errors[:symbol]).to include("can't be blank")
    end

    it "requires price" do
      record = build(:crypto_price, price: nil)
      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("can't be blank")
    end

    it "requires currency" do
      record = build(:crypto_price, currency: nil)
      expect(record).not_to be_valid
      expect(record.errors[:currency]).to include("can't be blank")
    end

    it "requires provider" do
      record = build(:crypto_price, provider: nil)
      expect(record).not_to be_valid
      expect(record.errors[:provider]).to include("can't be blank")
    end

    it "requires fetched_at" do
      record = build(:crypto_price, fetched_at: nil)
      expect(record).not_to be_valid
      expect(record.errors[:fetched_at]).to include("can't be blank")
    end

    it "requires price to be greater than zero" do
      record = build(:crypto_price, price: 0)
      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("must be greater than 0")
    end

    it "rejects negative price" do
      record = build(:crypto_price, price: -1)
      expect(record).not_to be_valid
      expect(record.errors[:price]).to include("must be greater than 0")
    end
  end

  describe "normalization" do
    it "normalizes symbol to uppercase before save" do
      record = create(:crypto_price, symbol: "BTC")
      expect(record.symbol).to eq("BTC")
    end

    it "normalizes symbol with mixed case before save" do
      record = create(:crypto_price, symbol: "Eth")
      expect(record.symbol).to eq("ETH")
    end

    it "normalizes currency to uppercase before save" do
      record = create(:crypto_price, currency: "USD")
      expect(record.currency).to eq("USD")
    end

    it "normalizes provider to lowercase before save" do
      record = create(:crypto_price, provider: "CoinGecko")
      expect(record.provider).to eq("coingecko")
    end
  end

  describe "database constraints" do
    it "enforces composite uniqueness on symbol, currency, and provider" do
      create(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")

      duplicate = build(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")
      expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "allows the same symbol with a different currency" do
      create(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")
      different_currency = build(:crypto_price, symbol: "btc", currency: "eur", provider: "coingecko")
      expect(different_currency).to be_valid
    end

    it "allows the same symbol with a different provider" do
      create(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")
      different_provider = build(:crypto_price, symbol: "btc", currency: "usd", provider: "other")
      expect(different_provider).to be_valid
    end

    it "does not enforce symbol-only uniqueness" do
      create(:crypto_price, symbol: "btc", currency: "usd", provider: "coingecko")
      create(:crypto_price, symbol: "btc", currency: "eur", provider: "coingecko")
      create(:crypto_price, symbol: "btc", currency: "usd", provider: "other")

      expect(CryptoPrice.where(symbol: "BTC").count).to eq(3)
    end
  end
end
# rubocop:enable Metrics/BlockLength
