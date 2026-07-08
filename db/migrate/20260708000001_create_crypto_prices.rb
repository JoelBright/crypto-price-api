class CreateCryptoPrices < ActiveRecord::Migration[8.1]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :crypto_prices do |t|
      t.string :symbol, null: false
      t.decimal :price, precision: 20, scale: 8, null: false
      t.string :currency, null: false, default: "USD"
      t.string :provider, null: false, default: "coingecko"
      t.datetime :fetched_at, null: false
      t.timestamps

      t.index [:symbol, :currency, :provider],
              unique: true,
              name: "index_crypto_prices_on_symbol_currency_provider"
    end
  end
  # rubocop:enable Metrics/MethodLength
end
