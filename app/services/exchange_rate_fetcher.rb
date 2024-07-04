require 'net/http'
require 'json'

class ExchangeRateFetcher
  BASE_URL = 'https://v6.exchangerate-api.com/v6/ff902769459ec23f6d4c49cd/latest/'.freeze
  TIMEOUT_LIMIT = 5 # seconds

  def initialize(original_currency)
    @original_currency = original_currency
  end

  def call
    response = fetch_exchange_rate
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data['conversion_rates']
    else
      raise ErrorMessages::EXCHANGE_RATE_FETCH_FAILED
    end
  rescue Timeout::Error
    raise ErrorMessages::REQUEST_TIMEOUT
  rescue StandardError => e
    raise e.message
  end

  private

  def fetch_exchange_rate
    uri = URI("#{BASE_URL}/#{@original_currency}")
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: TIMEOUT_LIMIT) do |http|
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end
  end
end
