# frozen_string_literal: true

class CurrenciesController < ApplicationController
  include CurrencyTools

  def currencies
    currency = current_user ? current_user.currency : "EUR"
    results = get_currency_array(currency, current_user.tenant_id)
    response_handler(results)
  end

  def get_currencies_for_base
    results = get_currency_array(params[:currency], current_user.tenant_id)
    response_handler(results)
  end

  def refresh_for_base
    results = refresh_rates_array(params[:currency])
    response_handler(results)
  end

  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = get_rates(params[:currency], current_user.tenant_id)
    response_handler(user: current_user.token_validation_response, rates: rates)
  end
end
