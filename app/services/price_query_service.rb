class PriceQueryService
  Result = Data.define(:found, :price_record) do
    def found?
      found
    end

    def not_found?
      !found
    end
  end

  def initialize(repository:, cache:)
    @repository = repository
    @cache = cache
  end

  def query(symbol:, currency: "USD", provider: "coingecko")
    cached = read_cache(symbol: symbol, currency: currency, provider: provider)
    return Result.new(found: true, price_record: cached) if cached

    persisted = repository.find(symbol: symbol, currency: currency, provider: provider)
    return Result.new(found: false, price_record: nil) unless persisted

    repopulate_cache(persisted)
    Result.new(found: true, price_record: persisted)
  end

  private

  attr_reader :repository, :cache

  def read_cache(symbol:, currency:, provider:)
    cache.read(symbol: symbol, currency: currency, provider: provider)
  rescue StandardError => e
    Rails.logger.warn(
      message: "Cache read failed, falling back to repository",
      error: e.class.name,
      symbol: symbol,
      currency: currency,
      provider: provider
    )
    nil
  end

  def repopulate_cache(price_record)
    cache.write(price_record)
  rescue StandardError => e
    Rails.logger.warn(
      message: "Cache repopulation failed after persistence fallback",
      error: e.class.name,
      symbol: price_record.symbol,
      currency: price_record.currency,
      provider: price_record.provider
    )
  end
end
