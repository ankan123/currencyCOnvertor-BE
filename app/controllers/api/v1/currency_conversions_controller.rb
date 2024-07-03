module Api
  module V1
    class CurrencyConversionsController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        #remove .all method and return convertors using serializer
        convertors = CurrencyConversion.all.order(created_at: :desc)
        render json: convertors
      end

      def create
        result = CurrencyConverterService.convert(conversion_params)
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
  
