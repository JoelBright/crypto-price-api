# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe Services do
  describe ".price_query" do
    it "returns a PriceQueryService" do
      expect(described_class.price_query).to be_a(PriceQueryService)
    end

    it "constructs the service with repository and cache dependencies" do
      allow(PriceQueryService).to receive(:new).and_call_original

      described_class.price_query

      expect(PriceQueryService).to have_received(:new).with(
        repository: an_instance_of(CryptoPriceRepository),
        cache: an_instance_of(PriceCache)
      )
    end

    it "does not memoize service instances" do
      expect(described_class.price_query).not_to equal(described_class.price_query)
    end
  end

  describe ".price_refresh" do
    it "returns a PriceRefreshService" do
      expect(described_class.price_refresh).to be_a(PriceRefreshService)
    end

    it "constructs the service with provider, repository, and cache dependencies" do
      allow(PriceRefreshService).to receive(:new).and_call_original

      described_class.price_refresh

      expect(PriceRefreshService).to have_received(:new).with(
        provider_client: an_instance_of(CoinGeckoClient),
        repository: an_instance_of(CryptoPriceRepository),
        cache: an_instance_of(PriceCache)
      )
    end

    it "does not memoize service instances" do
      expect(described_class.price_refresh).not_to equal(described_class.price_refresh)
    end
  end

  describe "service constructor injection" do
    it "keeps PriceQueryService explicitly injectable" do
      repository = instance_spy(CryptoPriceRepository)
      cache = instance_spy(PriceCache)

      service = PriceQueryService.new(repository: repository, cache: cache)

      expect(service).to be_a(PriceQueryService)
    end

    it "keeps PriceRefreshService explicitly injectable" do
      provider_client = instance_double(CoinGeckoClient)
      repository = instance_spy(CryptoPriceRepository)
      cache = instance_spy(PriceCache)

      service = PriceRefreshService.new(
        provider_client: provider_client,
        repository: repository,
        cache: cache
      )

      expect(service).to be_a(PriceRefreshService)
    end
  end
end
# rubocop:enable Metrics/BlockLength
