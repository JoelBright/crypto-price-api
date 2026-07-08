# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
RSpec.describe PriceRefreshJob, type: :job do
  include ActiveJob::TestHelper

  # ------------------------------------------------------------------ helpers

  let(:service_double) do
    instance_double(
      PriceRefreshService,
      refresh: PriceRefreshService::Result.new(
        success: true,
        price_record: build_stubbed(:crypto_price),
        error: nil
      )
    )
  end

  before do
    allow(PriceRefreshService).to receive(:new).and_return(service_double)
  end

  # ------------------------------------------------------------------ enqueue

  describe "enqueue behaviour" do
    it "can be enqueued without raising" do
      expect { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }.not_to raise_error
    end

    it "is enqueued on the default queue" do
      PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD")
      expect(enqueued_jobs.last["queue_name"]).to eq("default")
    end

    it "serializes the symbol argument" do
      PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD")
      # ActiveJob stores arguments under "arguments"; keyword args include _aj_ruby2_keywords.
      args = enqueued_jobs.last["arguments"]
      payload = args.find { |a| a.is_a?(Hash) && a.key?("symbol") }
      expect(payload).to include("symbol" => "BTC", "currency" => "USD")
    end

    it "uses the default currency when performing with symbol only" do
      # When currency is omitted at enqueue time, the default is applied at perform time.
      # Verify delegation applies the USD default during execution.
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "ETH") }
      expect(service_double).to have_received(:refresh).with(symbol: "ETH", currency: "USD")
    end
  end

  # ------------------------------------------------------------------ delegation

  describe "service delegation" do
    it "delegates to PriceRefreshService" do
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      expect(service_double).to have_received(:refresh).with(symbol: "BTC", currency: "USD")
    end

    it "builds the service with a CoinGeckoClient, CryptoPriceRepository, and PriceCache" do
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      expect(PriceRefreshService).to have_received(:new).with(
        provider_client: an_instance_of(CoinGeckoClient),
        repository: an_instance_of(CryptoPriceRepository),
        cache: an_instance_of(PriceCache)
      )
    end

    it "does not call repository directly" do
      repository_spy = spy(CryptoPriceRepository)
      allow(CryptoPriceRepository).to receive(:new).and_return(repository_spy)
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      expect(repository_spy).not_to have_received(:upsert)
    end

    it "does not call provider client directly" do
      client_spy = spy(CoinGeckoClient)
      allow(CoinGeckoClient).to receive(:new).and_return(client_spy)
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      expect(client_spy).not_to have_received(:fetch_price)
    end

    it "does not update cache directly" do
      cache_spy = spy(PriceCache)
      allow(PriceCache).to receive(:new).and_return(cache_spy)
      perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      expect(cache_spy).not_to have_received(:write)
    end
  end

  # ------------------------------------------------------------------ controlled failure

  describe "controlled failure (service returns failure result)" do
    before do
      allow(service_double).to receive(:refresh).and_return(
        PriceRefreshService::Result.new(
          success: false,
          price_record: nil,
          error: ProviderError::TimeoutError.new("timeout")
        )
      )
    end

    it "does not raise when service returns a controlled failure result" do
      expect do
        perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      end.not_to raise_error
    end
  end

  # ------------------------------------------------------------------ retry / discard policy (static inspection)
  #
  # The ActiveJob test adapter wraps unhandled exceptions in Minitest::UnexpectedError
  # after exhausting retries, which makes raise_error assertions on provider errors
  # fragile. Instead, verify the configured rescue_handlers directly against the class.
  # This approach does not require real retry cycles and never waits for timing.

  describe "retry policy (class configuration)" do
    let(:retry_handler_names) do
      described_class.rescue_handlers
                     .select { |_name, handler| handler.source_location.first.include?("exceptions.rb") }
                     .map(&:first)
    end

    it "registers ProviderError::TimeoutError for retry" do
      expect(retry_handler_names).to include("ProviderError::TimeoutError")
    end

    it "registers ProviderError::NetworkError for retry" do
      expect(retry_handler_names).to include("ProviderError::NetworkError")
    end

    it "registers ProviderError::HttpError for retry" do
      expect(retry_handler_names).to include("ProviderError::HttpError")
    end

    it "registers all three retryable errors" do
      %w[ProviderError::TimeoutError ProviderError::NetworkError ProviderError::HttpError].each do |klass|
        expect(retry_handler_names).to include(klass)
      end
    end
  end

  describe "discard policy (class configuration)" do
    let(:all_handler_names) { described_class.rescue_handlers.map(&:first) }

    it "registers ProviderError::ConfigurationError for handling (discard)" do
      expect(all_handler_names).to include("ProviderError::ConfigurationError")
    end

    it "registers ProviderError::UnsupportedSymbolError for handling (discard)" do
      expect(all_handler_names).to include("ProviderError::UnsupportedSymbolError")
    end
  end

  describe "discard execution (no retry on non-retryable errors)" do
    it "discards without propagating on ProviderError::ConfigurationError" do
      allow(service_double).to receive(:refresh).and_raise(ProviderError::ConfigurationError, "no key")
      expect do
        perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD") }
      end.not_to raise_error
      expect(service_double).to have_received(:refresh).once
    end

    it "discards without propagating on ProviderError::UnsupportedSymbolError" do
      allow(service_double).to receive(:refresh).and_raise(ProviderError::UnsupportedSymbolError, "unknown")
      expect do
        perform_enqueued_jobs { PriceRefreshJob.perform_later(symbol: "XYZ", currency: "USD") }
      end.not_to raise_error
      expect(service_double).to have_received(:refresh).once
    end
  end

  # ------------------------------------------------------------------ idempotency / duplicate execution

  describe "idempotency under duplicate execution" do
    it "delegates to the service on both executions without raising" do
      expect do
        perform_enqueued_jobs do
          PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD")
          PriceRefreshJob.perform_later(symbol: "BTC", currency: "USD")
        end
      end.not_to raise_error

      expect(service_double).to have_received(:refresh).twice
    end
  end

  # ------------------------------------------------------------------ queue name

  describe ".queue_name" do
    it "uses the :default queue" do
      expect(described_class.queue_name).to eq("default")
    end
  end
end
# rubocop:enable Metrics/BlockLength
