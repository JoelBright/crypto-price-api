class PriceResponseSerializer
  def initialize(price_record)
    @price_record = price_record
  end

  def as_json(*)
    {
      symbol: value_for(:symbol).to_s.downcase,
      price: serialized_price,
      currency: value_for(:currency).to_s.downcase,
      last_updated_at: serialized_timestamp
    }
  end

  private

  attr_reader :price_record

  def serialized_price
    BigDecimal(value_for(:price).to_s).to_s("F").to_f
  end

  def serialized_timestamp
    value_for(:fetched_at).utc.iso8601
  end

  def value_for(attribute)
    return price_record[attribute] if price_record.is_a?(Hash) && price_record.key?(attribute)
    return price_record[attribute.to_s] if price_record.is_a?(Hash) && price_record.key?(attribute.to_s)

    price_record.public_send(attribute)
  end
end
