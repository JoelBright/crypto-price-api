class PriceCache
  def initialize(cache_store: Rails.cache)
    @cache_store = cache_store
  end

  def key(symbol:, currency:, provider:)
    "prices:#{normalize_provider(provider)}:#{normalize_symbol(symbol)}:#{normalize_currency(currency)}"
  end

  def read(symbol:, currency:, provider:)
    cache_store.read(key(symbol: symbol, currency: currency, provider: provider))
  end

  def write(price_record, expires_in: nil)
    cache_store.write(
      key(symbol: price_record.symbol, currency: price_record.currency, provider: price_record.provider),
      payload_for(price_record),
      expires_in: expires_in
    )
  end

  def delete(symbol:, currency:, provider:)
    cache_store.delete(key(symbol: symbol, currency: currency, provider: provider))
  end

  private

  attr_reader :cache_store

  def payload_for(price_record)
    {
      symbol: normalize_symbol(price_record.symbol),
      price: price_record.price,
      currency: normalize_currency(price_record.currency),
      provider: normalize_provider(price_record.provider),
      fetched_at: price_record.fetched_at
    }
  end

  def normalize_symbol(value)
    value.to_s.strip.upcase
  end

  def normalize_currency(value)
    value.to_s.strip.upcase
  end

  def normalize_provider(value)
    value.to_s.strip.downcase
  end
end
