class ApplicationJob < ActiveJob::Base
  # ActiveJob queue adapters are configured per environment in config/environments/*.rb.
  #
  # Development and production use :solid_queue (accepted in ADR-017).
  # Test environment uses :test to allow specs to control job execution explicitly.
end
