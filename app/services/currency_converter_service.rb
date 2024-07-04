require 'net/http'
require 'json'

class CurrencyConverterService
  BASE_URL = 'https://v6.exchangerate-api.com/v6/ff902769459ec23f6d4c49cd/latest/'.freeze
  TIMEOUT_LIMIT = 5 # seconds

  def initialize(params)
    @params = params
  end

  def call
    exchange_rate_response = ExchangeRateFetcher.new(@params[:original_currency]).call
    exchange_rate = exchange_rate_response.dig(@params[:target_currency])
    converted_amount = (sanitized_amount * exchange_rate).round(2)

    currency_conversion = CurrencyConversion.create(@params.merge!(original_amount: sanitized_amount, converted_amount: converted_amount, exchange_rate: exchange_rate).except(:amount))
  rescue StandardError => e
    raise e.message
  end

  private

  def sanitized_amount
    @sanitized_amount ||= @params[:amount].to_f
  end
end
