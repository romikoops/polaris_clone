class Admin::CurrenciesController < ApplicationController
  include CurrencyTools

  def currencies
    currency = current_user ? current_user.currency : "USD"
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
    response_handler(user: current_user, rates: rates)
  end

  def toggle_mode
    tenant = Tenant.find(current_user.tenant_id)
    tenant.scope["fixed_currency"] = !tenant.scope["fixed_currency"]
    tenant.save!
    currency = tenant ? tenant.currency : "USD"
    rates = get_currency_array(currency, tenant.id)
    response_handler(tenant: tenant, rates: rates)
  end

  def set_rates

    currency = Currency.find_or_create_by(tenant_id: current_user.tenant_id, base: params[:base])
    currency.update_attributes(today: params[:rates])
    results = get_currency_array(params[:base], current_user.tenant_id)
    response_handler(results)
  end

end
