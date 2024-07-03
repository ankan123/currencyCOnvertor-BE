class CurrencyConversionSerializer < ActiveModel::Serializer
  attributes :id, :original_currency, :target_currency, :original_amount, :converted_amount, :exchange_rate, :created_at
end
