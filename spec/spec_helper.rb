require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch
  add_filter "/spec/"
  # Provisional: raise to 90 when domain code and meaningful specs exist (Phase 2+)
  minimum_coverage 0
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
