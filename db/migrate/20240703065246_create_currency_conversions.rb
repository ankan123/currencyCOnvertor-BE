class CreateCurrencyConversions < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_conversions do |t|
      t.string :original_currency
      t.string :target_currency
      t.decimal :original_amount
      t.decimal :converted_amount
      t.decimal :exchange_rate

      t.timestamps
    end
  end
end
