require "spec_helper"

ENV["RAILS_ENV"] ||= "test"
require_relative "../../config/environment"

RSpec.describe "Rails application foundation" do
  it "loads the application in API mode" do
    expect(Rails.application).to be_present
    expect(Rails.application.config.api_only).to be(true)
  end
end
