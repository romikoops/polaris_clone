# frozen_string_literal: true

require_dependency 'admiralty_reports/application_controller'

module AdmiraltyReports
  class ReportsController < ApplicationController
    MONTH_LOOKUP = Date::MONTHNAMES[1..12].zip(1..12).freeze

    def index
      @tenants = Tenant.order(:subdomain).all
      first_year = Legacy::Shipment.order(:created_at).first&.created_at&.year || Time.now.year
      @possible_years = (first_year..Time.now.year).to_a
    end

    def show
      @tenant = Tenant.find(params[:id])
      @month = filter_params[:month]
      @year = filter_params[:year]
      @stats = Stats.new(tenant: @tenant, month: @month, year: @year)
    end

    private

    def filter_params
      params.permit(:month, :year)
    end
  end
end
