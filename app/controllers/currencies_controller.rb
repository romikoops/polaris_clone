# frozen_string_literal: true

class CurrenciesController < ApplicationController

  def currencies
    currency = current_user ? current_user.currency : 'EUR'
    results = CurrencyTools.new.get_currency_array(currency, params[:tenant_id] || current_user.tenant_id)
    response_handler(results)
  end

  def get_currencies_for_base
    results = CurrencyTools.new.get_currency_array(params[:currency], params[:tenant_id] || current_user.tenant_id)
    response_handler(results)
  end

  def refresh_for_base
    results = CurrencyTools.new.refresh_rates_array(params[:currency])
    response_handler(results)
  end

  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = CurrencyTools.new.get_rates(params[:currency], params[:tenant_id] || current_user.tenant_id)
    response_handler(user: current_user.token_validation_response, rates: rates)
  end
end
