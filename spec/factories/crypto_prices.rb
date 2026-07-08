FactoryBot.define do
  factory :crypto_price do
    symbol { "BTC" }
    price { 50_000.00 }
    currency { "USD" }
    provider { "coingecko" }
    fetched_at { Time.current }
  end
end
