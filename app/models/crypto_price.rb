class CryptoPrice < ApplicationRecord
  validates :symbol, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :provider, presence: true
  validates :fetched_at, presence: true

  before_save :normalize_symbol
  before_save :normalize_currency
  before_save :normalize_provider

  private

  def normalize_symbol
    self.symbol = symbol.strip.upcase if symbol.present?
  end

  def normalize_currency
    self.currency = currency.strip.upcase if currency.present?
  end

  def normalize_provider
    self.provider = provider.strip.downcase if provider.present?
  end
end
