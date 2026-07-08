class PriceRefreshService
  Result = Data.define(:success, :price_record, :error) do
    def success?
      success
    end

    def failure?
      !success
    end
  end

  def initialize(provider_client:, repository:, cache:)
    @provider_client = provider_client
    @repository = repository
    @cache = cache
  end

  def refresh(symbol:, currency: "USD")
    provider_data = fetch_provider(symbol: symbol, currency: currency)
    return provider_data unless provider_data.success?

    persisted = persist_price(provider_data.price_record)
    return persisted unless persisted.success?

    update_cache(persisted.price_record)

    persisted
  end

  private

  attr_reader :provider_client, :repository, :cache

  # rubocop:disable Metrics/MethodLength
  def fetch_provider(symbol:, currency:)
    data = provider_client.fetch_price(symbol: symbol, currency: currency)
    Result.new(success: true, price_record: data, error: nil)
  rescue ProviderError::Error => e
    Rails.logger.warn(
      message: "Provider fetch failed, preserving existing data",
      provider: "coingecko",
      symbol: symbol,
      currency: currency,
      error: e.class.name
    )
    Result.new(success: false, price_record: nil, error: e)
  end
  # rubocop:enable Metrics/MethodLength

  def persist_price(provider_data) # rubocop:disable Metrics/MethodLength
    record = repository.upsert( # rubocop:disable Rails/SkipsModelValidations
      symbol: provider_data.fetch(:symbol),
      price: provider_data.fetch(:price),
      currency: provider_data.fetch(:currency),
      provider: provider_data.fetch(:provider),
      fetched_at: provider_data.fetch(:fetched_at)
    )
    Result.new(success: true, price_record: record, error: nil)
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    Rails.logger.error(
      message: "Persistence failed after valid provider response, cache will not be updated",
      error: e.class.name,
      symbol: provider_data.fetch(:symbol)
    )
    Result.new(success: false, price_record: nil, error: e)
  end

  def update_cache(price_record)
    cache.write(price_record)
  rescue StandardError => e
    Rails.logger.warn(
      message: "Cache write failed after successful persistence, durable data preserved",
      error: e.class.name,
      symbol: price_record.symbol,
      currency: price_record.currency,
      provider: price_record.provider
    )
  end
end
