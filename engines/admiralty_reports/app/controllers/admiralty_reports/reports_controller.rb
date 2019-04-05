# frozen_string_literal: true

require_dependency 'admiralty_reports/application_controller'

module AdmiraltyReports
  class ReportsController < ApplicationController
    def index
      @tenants = ::Legacy::Tenant.order(:subdomain).all
    end

    def show
      @tenant = ::Legacy::Tenant.find(params[:id])
      @stats = if quotation_tool?(tenant)
                 StatsCreator::Quotations.new(tenant).perform
               else
                 StatsCreator::Bookings.new(tenant).perform
               end

      @stats = [] if @stats.nil?
    end

    private

    attr_reader :tenant

    def quotation_tool?(tenant)
      tenant.scope.select { |k, _v| k.to_s.include?('quotation_tool') }.values.any?
    end
  end
end
