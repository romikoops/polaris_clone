# frozen_string_literal: true

class Admin::CurrenciesController < ApplicationController
  def currencies
    currency = current_user ? current_user.currency : 'USD'
    results = CurrencyTools.new.get_currency_array(currency, params[:tenant_id])
    response_handler(results)
  end

  def get_currencies_for_base
    results = CurrencyTools.new.get_currency_array(params[:currency], params[:tenant_id])
    response_handler(results)
  end

  def refresh_for_base
    results = CurrencyTools.new.refresh_rates_array(params[:currency], params[:tenant_id])
    response_handler(results)
  end

  def set_currency
    current_user.currency = params[:currency]
    current_user.save!
    rates = CurrencyTools.new.get_rates(params[:currency], params[:tenant_id])
    response_handler(user: current_user, rates: rates)
  end

  def toggle_mode
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: current_tenant.id)
    scope = ::Tenants::ScopeService.new(target: current_user, tenant: tenants_tenant).fetch
    scope.content[:fixed_exchange_rate] = !scope.content[:fixed_exchange_rate]
    scope.save!
    currency = tenant ? tenant.currency : 'USD'
    rates = CurrencyTools.new.get_currency_array(currency, tenant.id)
    response_handler(tenant: tenant, rates: rates)
  end

  def set_rates
    currency = Currency.find_or_create_by(tenant_id: params[:tenant_id], base: params[:base])
    currency.update_attributes(today: params[:rates])
    results = CurrencyTools.new.get_currency_array(params[:base], params[:tenant_id])
    response_handler(results)
  end
end
