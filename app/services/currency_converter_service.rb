require 'net/http'
require 'json'

class CurrencyConverterService
  BASE_URL = 'https://v6.exchangerate-api.com/v6/ff902769459ec23f6d4c49cd/latest/'.freeze
  TIMEOUT_LIMIT = 5 # seconds

  def initialize(params)
    @params = params
    @original_currency = @params[:original_currency]
    @target_currency = @params[:target_currency]
    @amount = @params[:amount].to_f
  end

  def call
    validation = validate_params
    return validation unless validation.success?

    response = fetch_exchange_rate

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      exchange_rate = data['conversion_rates'][@target_currency]
      converted_amount = (@amount.to_f * exchange_rate).round(2)

      currency_conversion = CurrencyConversion.create(
        original_currency: @original_currency,
        target_currency: @target_currency,
        original_amount: @amount,
        converted_amount: converted_amount,
        exchange_rate: exchange_rate
      )

      OpenStruct.new(success?: true, result: currency_conversion)
    else
      OpenStruct.new(success?: false, error: 'Failed to fetch exchange rate')
    end
  rescue Timeout::Error
    OpenStruct.new(success?: false, error: 'The request timed out')
  rescue StandardError => e
    OpenStruct.new(success?: false, error: e.message)
  end

  private

  def validate_params
    missing_params = %i[original_currency target_currency amount].select { |param| @params[param].blank? }
    if missing_params.any?
      OpenStruct.new(success?: false, error: "Missing required parameters: #{missing_params.join(', ')}")
    else
      OpenStruct.new(success?: true)
    end
  end

  def fetch_exchange_rate
    uri = URI("#{BASE_URL}/#{@original_currency}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: TIMEOUT_LIMIT) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end
  end
end
