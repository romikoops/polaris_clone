# frozen_string_literal: true

class CurrenciesController < ApplicationController
  def currencies_for_base
    results = Legacy::CurrencyTools.new.get_currency_array(
      params[:currency], params[:tenant_id] || current_user.tenant_id
    )

    response_handler(results)
  end

  def refresh_for_base
    results = Legacy::CurrencyTools.new.refresh_rates_array(params[:currency])
    response_handler(results)
  end
end
