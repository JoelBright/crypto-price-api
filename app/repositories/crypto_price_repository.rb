class CryptoPriceRepository
  def find(symbol:, currency:, provider:)
    CryptoPrice.find_by(
      symbol: normalize_symbol(symbol),
      currency: normalize_currency(currency),
      provider: normalize_provider(provider)
    )
  end

  def upsert(symbol:, price:, currency:, provider:, fetched_at:)
    record = CryptoPrice.find_or_initialize_by(
      symbol: normalize_symbol(symbol),
      currency: normalize_currency(currency),
      provider: normalize_provider(provider)
    )

    record.assign_attributes(price: price, fetched_at: fetched_at)
    record.save!
    record
  end

  private

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
