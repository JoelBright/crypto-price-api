# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe PriceQueryService do
  subject(:service) { described_class.new(repository: repository, cache: cache) }

  let(:repository) { instance_spy(CryptoPriceRepository) }
  let(:cache) { instance_spy(PriceCache) }

  let(:persisted_price) do
    build_stubbed(
      :crypto_price,
      symbol: "BTC",
      price: BigDecimal("50001.00"),
      currency: "USD",
      provider: "coingecko",
      fetched_at: Time.zone.parse("2026-07-08 12:00:00 UTC")
    )
  end

  let(:default_params) { { symbol: "BTC", currency: "USD", provider: "coingecko" } }

  describe "#query" do
    context "when cache hit" do
      let(:cache_payload) do
        {
          symbol: "BTC",
          price: BigDecimal("50001.00"),
          currency: "USD",
          provider: "coingecko",
          fetched_at: Time.zone.parse("2026-07-08 12:00:00 UTC")
        }
      end

      before do
        allow(cache).to receive(:read).with(**default_params).and_return(cache_payload)
      end

      it "returns a found result" do
        result = service.query(**default_params)
        expect(result).to be_found
      end

      it "returns the cached payload" do
        result = service.query(**default_params)
        expect(result.price_record).to eq(cache_payload)
      end

      it "does not query the repository" do
        service.query(**default_params)
        expect(repository).not_to have_received(:find)
      end
    end

    context "when cache miss with persisted record" do
      before do
        allow(cache).to receive(:read).with(**default_params).and_return(nil)
        allow(repository).to receive(:find).with(**default_params).and_return(persisted_price)
      end

      it "returns a found result" do
        result = service.query(**default_params)
        expect(result).to be_found
      end

      it "returns the persisted price record" do
        result = service.query(**default_params)
        expect(result.price_record).to eq(persisted_price)
      end

      it "repopulates the cache from the persisted record" do
        service.query(**default_params)
        expect(cache).to have_received(:write).with(persisted_price)
      end

      it "queries the repository" do
        service.query(**default_params)
        expect(repository).to have_received(:find).with(**default_params)
      end
    end

    context "when no cached or persisted value exists" do
      before do
        allow(cache).to receive(:read).with(**default_params).and_return(nil)
        allow(repository).to receive(:find).with(**default_params).and_return(nil)
      end

      it "returns a not-found result" do
        result = service.query(**default_params)
        expect(result).not_to be_found
      end

      it "returns nil for price_record" do
        result = service.query(**default_params)
        expect(result.price_record).to be_nil
      end

      it "does not write to cache" do
        service.query(**default_params)
        expect(cache).not_to have_received(:write)
      end
    end

    context "when cache read fails" do
      before do
        allow(cache).to receive(:read).with(**default_params).and_raise(StandardError, "cache down")
        allow(repository).to receive(:find).with(**default_params).and_return(persisted_price)
      end

      it "falls back to the repository" do
        result = service.query(**default_params)
        expect(result).to be_found
        expect(result.price_record).to eq(persisted_price)
      end

      it "attempts to repopulate cache from persisted data" do
        service.query(**default_params)
        expect(cache).to have_received(:write).with(persisted_price)
      end

      it "queries the repository" do
        service.query(**default_params)
        expect(repository).to have_received(:find).with(**default_params)
      end
    end

    context "when cache read fails and no persisted value exists" do
      before do
        allow(cache).to receive(:read).with(**default_params).and_raise(StandardError, "cache down")
        allow(repository).to receive(:find).with(**default_params).and_return(nil)
      end

      it "returns a not-found result" do
        result = service.query(**default_params)
        expect(result).not_to be_found
      end
    end

    context "when cache repopulation fails" do
      before do
        allow(cache).to receive(:read).with(**default_params).and_return(nil)
        allow(repository).to receive(:find).with(**default_params).and_return(persisted_price)
        allow(cache).to receive(:write).with(persisted_price).and_raise(StandardError, "write failure")
      end

      it "still returns a found result with the persisted record" do
        result = service.query(**default_params)
        expect(result).to be_found
        expect(result.price_record).to eq(persisted_price)
      end
    end

    it "never calls CoinGecko" do
      expect(CoinGeckoClient).not_to receive(:new)
      service.query(**default_params)
    end
  end

  describe "Result" do
    it "exposes predicate methods" do
      found = described_class::Result.new(found: true, price_record: :value)
      expect(found).to be_found
      expect(found).not_to be_not_found

      not_found = described_class::Result.new(found: false, price_record: nil)
      expect(not_found).to be_not_found
      expect(not_found).not_to be_found
    end
  end
end
# rubocop:enable Metrics/BlockLength
