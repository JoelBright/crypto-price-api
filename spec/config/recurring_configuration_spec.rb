# frozen_string_literal: true

require "rails_helper"

# Verifies the Solid Queue recurring schedule configuration without waiting
# for a real one-minute interval. Loads and inspects config/recurring.yml
# exactly as Solid Queue does at boot.
#
# Test approach per docs/TESTING.md section 12 (Scheduler Verification):
#   - Schedule definition includes the expected one-minute interval.
#   - Scheduler is configured to enqueue PriceRefreshJob.
#   - Configuration is loaded successfully in the expected environment.
#   - Configuration uses the expected symbols and quote currency.

# rubocop:disable Metrics/BlockLength
RSpec.describe "config/recurring.yml", type: :config do
  subject(:recurring_config) do
    # Load using ActiveSupport::ConfigurationFile as Solid Queue does,
    # then deep_symbolize_keys to match Solid Queue's internal representation.
    ActiveSupport::ConfigurationFile
      .parse(Rails.root.join("config/recurring.yml"))
      .deep_symbolize_keys
  end

  let(:env_tasks) do
    # config_from selects env key if present, else falls back to root config.
    recurring_config[:development] || recurring_config
  end

  it "loads without error" do
    expect { recurring_config }.not_to raise_error
  end

  it "provides at least two recurring tasks" do
    expect(env_tasks.size).to be >= 2
  end

  it "includes a task for BTC price refresh" do
    expect(env_tasks).to have_key(:price_refresh_btc)
  end

  it "includes a task for ETH price refresh" do
    expect(env_tasks).to have_key(:price_refresh_eth)
  end

  describe "BTC task definition" do
    subject(:task) { env_tasks[:price_refresh_btc] }

    it "delegates to PriceRefreshJob" do
      expect(task[:class]).to eq("PriceRefreshJob")
    end

    it "schedules every minute" do
      expect(task[:schedule]).to match(/every minute/i)
    end

    it "targets the default queue" do
      expect(task[:queue]).to eq("default")
    end

    it "passes BTC as the symbol argument" do
      args = task[:args]
      symbol_arg = args.flatten.find { |a| a.is_a?(Hash) && a.key?(:symbol) }
      expect(symbol_arg[:symbol]).to eq("BTC")
    end

    it "passes USD as the currency argument" do
      args = task[:args]
      currency_arg = args.flatten.find { |a| a.is_a?(Hash) && a.key?(:currency) }
      expect(currency_arg[:currency]).to eq("USD")
    end
  end

  describe "ETH task definition" do
    subject(:task) { env_tasks[:price_refresh_eth] }

    it "delegates to PriceRefreshJob" do
      expect(task[:class]).to eq("PriceRefreshJob")
    end

    it "schedules every minute" do
      expect(task[:schedule]).to match(/every minute/i)
    end

    it "targets the default queue" do
      expect(task[:queue]).to eq("default")
    end

    it "passes ETH as the symbol argument" do
      args = task[:args]
      symbol_arg = args.flatten.find { |a| a.is_a?(Hash) && a.key?(:symbol) }
      expect(symbol_arg[:symbol]).to eq("ETH")
    end

    it "passes USD as the currency argument" do
      args = task[:args]
      currency_arg = args.flatten.find { |a| a.is_a?(Hash) && a.key?(:currency) }
      expect(currency_arg[:currency]).to eq("USD")
    end
  end

  describe "production task set" do
    subject(:production_tasks) { recurring_config[:production] }

    it "includes BTC and ETH refresh tasks" do
      expect(production_tasks).to have_key(:price_refresh_btc)
      expect(production_tasks).to have_key(:price_refresh_eth)
    end

    it "includes a maintenance task to clear finished jobs" do
      expect(production_tasks).to have_key(:clear_solid_queue_finished_jobs)
    end
  end
end
# rubocop:enable Metrics/BlockLength
