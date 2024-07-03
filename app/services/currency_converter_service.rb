require 'net/http'
require 'json'

class CurrencyConverterService
  API_URL = 'https://v6.exchangerate-api.com/v6/ff902769459ec23f6d4c49cd/latest/'

  def self.convert(conversion_params)
    original_currency = conversion_params[:original_currency]
    target_currency = conversion_params[:target_currency]
    amount = conversion_params[:amount]

    response = Net::HTTP.get(URI("#{API_URL}#{original_currency}"))
    data = JSON.parse(response)

    exchange_rate = data['conversion_rates'][target_currency]
    converted_amount = amount.to_f * exchange_rate

    { 
      original_currency: original_currency, 
      target_currency: target_currency, 
      original_amount: amount, 
      converted_amount: converted_amount, 
      exchange_rate: exchange_rate 
    }
  end
end
