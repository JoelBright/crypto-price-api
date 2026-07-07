require "erb"
require "yaml"

RSpec.describe "database configuration" do
  around do |example|
    original_database_url = ENV.delete("DATABASE_URL")
    original_test_database_url = ENV.delete("TEST_DATABASE_URL")

    example.run
  ensure
    ENV["DATABASE_URL"] = original_database_url if original_database_url
    ENV["TEST_DATABASE_URL"] = original_test_database_url if original_test_database_url
  end

  it "uses local PostgreSQL defaults without forcing TCP URLs when database URLs are absent" do
    rendered = ERB.new(File.read("config/database.yml")).result
    config = YAML.safe_load(rendered, aliases: true)

    expect(config.fetch("development").fetch("url")).to be_nil
    expect(config.fetch("test").fetch("url")).to be_nil
    expect(config.fetch("development")).to include(
      "adapter" => "postgresql",
      "database" => "crypto_price_api_development"
    )
    expect(config.fetch("test")).to include(
      "adapter" => "postgresql",
      "database" => "crypto_price_api_test"
    )
  end
end
