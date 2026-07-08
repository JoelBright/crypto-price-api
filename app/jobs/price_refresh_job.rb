class PriceRefreshJob < ApplicationJob
  queue_as :default

  # Retryable provider errors: transient network and server-side failures.
  # Bounded to 3 attempts (1 original + 2 retries) with linear wait.
  retry_on(
    ProviderError::TimeoutError,
    ProviderError::NetworkError,
    ProviderError::HttpError,
    attempts: 3,
    wait: 5.seconds
  )

  # Non-retryable provider errors: configuration or unsupported symbol.
  # Discard immediately — retrying won't help until engineering resolves the root cause.
  discard_on(
    ProviderError::ConfigurationError,
    ProviderError::UnsupportedSymbolError
  )

  # rubocop:disable Metrics/MethodLength
  def perform(symbol:, currency: "USD")
    Rails.logger.info(
      message: "PriceRefreshJob started",
      symbol: symbol,
      currency: currency,
      attempt: executions
    )

    service = build_service
    result = service.refresh(symbol: symbol, currency: currency)

    if result.success?
      Rails.logger.info(
        message: "PriceRefreshJob completed successfully",
        symbol: symbol,
        currency: currency
      )
    else
      Rails.logger.warn(
        message: "PriceRefreshJob completed with a controlled failure",
        symbol: symbol,
        currency: currency,
        error: result.error&.class&.name
      )
    end
  end
  # rubocop:enable Metrics/MethodLength

  private

  def build_service
    PriceRefreshService.new(
      provider_client: CoinGeckoClient.new,
      repository: CryptoPriceRepository.new,
      cache: PriceCache.new
    )
  end
end
