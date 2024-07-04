module Api
  module V1
    class CurrencyConversionsController < ApplicationController
      protect_from_forgery with: :null_session
      before_action :validate_params, only: [:create]

      def index
        convertors = CurrencyConversion.order(created_at: :desc)
        render json: convertors, each_serializer: CurrencyConversionSerializer
      end

      def create
        @conversion = CurrencyConverterService.new(conversion_params).call
        if @conversion
          render json: @conversion, each_serializer: CurrencyConversionSerializer, status: :created
        end
      rescue StandardError => e
        render json: ErrorSerializer.serialize(e.message), status: :unprocessable_entity
      end

      private

      def validate_params
        required_params = %i[original_currency target_currency amount]
        missing_params = required_params.select { |param| params[:currency_conversion][param].blank? }

        unless missing_params.empty?
          render json: ErrorSerializer.serialize(format(ErrorMessages::MISSING_PARAMS, missing_params.join(', '))), status: :unprocessable_entity and return
        end

        unless params[:currency_conversion][:original_currency].is_a?(String) && params[:currency_conversion][:target_currency].is_a?(String)
          render json: ErrorSerializer.serialize(ErrorMessages::INVALID_CURRENCY_TYPE), status: :unprocessable_entity and return
        end

        amount = params[:currency_conversion][:amount].to_f
        if amount <= 0
          render json: ErrorSerializer.serialize(ErrorMessages::INVALID_AMOUNT), status: :unprocessable_entity and return
        end
      end

      def conversion_params
        params.require(:currency_conversion).permit(:original_currency, :target_currency, :amount)
      end
    end
  end
end
