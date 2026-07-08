# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe PriceRefreshService do
  subject(:service) { described_class.new(provider_client: provider_client, repository: repository, cache: cache) }

  let(:provider_client) { instance_double(CoinGeckoClient) }
  let(:repository) { instance_spy(CryptoPriceRepository) }
  let(:cache) { instance_spy(PriceCache) }

  let(:provider_data) do
    {
      symbol: "BTC",
      price: BigDecimal("51000.00"),
      currency: "USD",
      provider: "coingecko",
      fetched_at: Time.zone.parse("2026-07-08 13:00:00 UTC")
    }
  end

  let(:persisted_price) do
    build_stubbed(
      :crypto_price,
      symbol: "BTC",
      price: BigDecimal("51000.00"),
      currency: "USD",
      provider: "coingecko",
      fetched_at: Time.zone.parse("2026-07-08 13:00:00 UTC")
    )
  end

  let(:default_params) { { symbol: "BTC", currency: "USD" } }

  describe "#refresh" do
    context "when provider returns valid data and persistence succeeds" do
      before do
        allow(provider_client).to receive(:fetch_price).with(**default_params).and_return(provider_data)
        allow(repository).to receive(:upsert).and_return(persisted_price)
      end

      it "returns a successful result" do
        result = service.refresh(**default_params)
        expect(result).to be_success
      end

      it "returns the persisted price record" do
        result = service.refresh(**default_params)
        expect(result.price_record).to eq(persisted_price)
      end

      it "persists the provider data through the repository" do
        service.refresh(**default_params)
        expect(repository).to have_received(:upsert).with(
          symbol: provider_data[:symbol],
          price: provider_data[:price],
          currency: provider_data[:currency],
          provider: provider_data[:provider],
          fetched_at: provider_data[:fetched_at]
        )
      end

      it "updates the cache after persistence" do
        service.refresh(**default_params)
        expect(cache).to have_received(:write).with(persisted_price)
      end

      it "writes the cache after the repository upsert" do
        service.refresh(**default_params)
        expect(repository).to have_received(:upsert).ordered
        expect(cache).to have_received(:write).ordered
      end
    end

    context "when the provider fails" do
      before do
        allow(provider_client).to receive(:fetch_price)
          .with(**default_params)
          .and_raise(ProviderError::TimeoutError, "CoinGecko request timed out")
      end

      it "returns a failure result" do
        result = service.refresh(**default_params)
        expect(result).to be_failure
      end

      it "returns the provider error" do
        result = service.refresh(**default_params)
        expect(result.error).to be_a(ProviderError::TimeoutError)
      end

      it "does not persist anything" do
        service.refresh(**default_params)
        expect(repository).not_to have_received(:upsert)
      end

      it "does not update the cache" do
        service.refresh(**default_params)
        expect(cache).not_to have_received(:write)
      end
    end

    context "when persistence fails" do
      before do
        allow(provider_client).to receive(:fetch_price).with(**default_params).and_return(provider_data)
        allow(repository).to receive(:upsert).and_raise(ActiveRecord::RecordInvalid.new(persisted_price))
      end

      it "returns a failure result" do
        result = service.refresh(**default_params)
        expect(result).to be_failure
      end

      it "does not update the cache" do
        service.refresh(**default_params)
        expect(cache).not_to have_received(:write)
      end
    end

    context "when cache write fails after successful persistence" do
      before do
        allow(provider_client).to receive(:fetch_price).with(**default_params).and_return(provider_data)
        allow(repository).to receive(:upsert).and_return(persisted_price)
        allow(cache).to receive(:write).with(persisted_price).and_raise(StandardError, "cache unavailable")
      end

      it "still returns a successful result" do
        result = service.refresh(**default_params)
        expect(result).to be_success
      end

      it "still returns the persisted price record" do
        result = service.refresh(**default_params)
        expect(result.price_record).to eq(persisted_price)
      end

      it "still persists the data" do
        service.refresh(**default_params)
        expect(repository).to have_received(:upsert)
      end
    end

    context "network error from provider" do
      before do
        allow(provider_client).to receive(:fetch_price)
          .with(**default_params)
          .and_raise(ProviderError::NetworkError, "CoinGecko network request failed")
      end

      it "returns a failure result" do
        result = service.refresh(**default_params)
        expect(result).to be_failure
      end

      it "does not persist or cache" do
        service.refresh(**default_params)
        expect(repository).not_to have_received(:upsert)
        expect(cache).not_to have_received(:write)
      end
    end

    context "malformed response from provider" do
      before do
        allow(provider_client).to receive(:fetch_price)
          .with(**default_params)
          .and_raise(ProviderError::MalformedResponseError, "invalid data")
      end

      it "returns a failure result" do
        result = service.refresh(**default_params)
        expect(result).to be_failure
      end
    end

    it "does not know controllers, HTTP responses, or scheduler concepts" do
      expect(service).not_to respond_to(:render)
      expect(service).not_to respond_to(:scheduler)
      expect(service).not_to respond_to(:enqueue)
    end
  end

  describe "Result" do
    it "exposes predicate methods" do
      success = described_class::Result.new(success: true, price_record: :value, error: nil)
      expect(success).to be_success
      expect(success).not_to be_failure

      failure = described_class::Result.new(success: false, price_record: nil, error: StandardError.new("boom"))
      expect(failure).to be_failure
      expect(failure).not_to be_success
    end
  end
end
# rubocop:enable Metrics/BlockLength
