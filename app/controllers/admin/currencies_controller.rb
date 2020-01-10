# frozen_string_literal: true

class Admin::CurrenciesController < ApplicationController

  def toggle_mode
    tenants_tenant = Tenants::Tenant.find_by(legacy_id: current_tenant.id)
    scope = tenants_tenant.scope
    scope.content[:fixed_exchange_rate] = !scope.content[:fixed_exchange_rate]
    scope.save!

    rates = Legacy::CurrencyTools.new.get_currency_array(current_tenant.currency, current_tenant&.id)
    response_handler(tenant: current_tenant, rates: rates)
  end

  def set_rates
    currency = Currency.find_or_create_by(tenant_id: params[:tenant_id], base: params[:base])
    currency.update(today: params[:rates])
    results = Legacy::CurrencyTools.new.get_currency_array(params[:base], params[:tenant_id])
    response_handler(results)
  end
end
