module Api
  module V1
    class CurrencyConversionsController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        convertors = CurrencyConversion.order(created_at: :desc)
        render json: convertors, each_serializer: CurrencyConversionSerializer
      end

      def create
        @conversion = CurrencyConverterService.new(conversion_params).call

        if @conversion.success?
          render json: @conversion.result, each_serializer: CurrencyConversionSerializer, status: :created
        else
          render status: :unprocessable_entity, json: { error: @conversion.error }
        end
      rescue StandardError => e
        render status: :unprocessable_entity, json: { error: e.message }
      end

      private

      def conversion_params
        params.require(:currency_conversion).permit(:original_currency, :target_currency, :amount)
      end
    end
  end
end
