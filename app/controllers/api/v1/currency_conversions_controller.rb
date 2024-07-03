module Api
  module V1
    class CurrencyConversionsController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        convertors = CurrencyConversion.all.order(created_at: :desc)
        render json: convertors
      end

      def create
        #Before calling converter service validate the params using validator service and return the error
        result = CurrencyConverterService.convert(conversion_params).
        #It's better to use resque block to cache any error and return error using error serializer or error class something with proper error message
        if conversion = CurrencyConversion.create(result)
          render json: conversion, serializer: CurrencyConversionSerializer
        else
          render status: :unprocessable_entity, json: { error: 'Failed to convert currency' }
      end
      end

      private

      def conversion_params
        params.require(:currency_conversion).permit(:original_currency, :target_currency, :amount)
      end
    end
  end
end
  
