# frozen_string_literal: true

require_dependency 'admiralty_reports/application_controller'

module AdmiraltyReports
  class ReportsController < ApplicationController
    def index
      @tenants = Tenant.order(:subdomain).all
    end

    def show
      @tenant = Tenant.find(params[:id])
      @stats = if quotation_tool?(tenant)
                 StatsCreator::Quotations.new(tenant.legacy).perform
               else
                 StatsCreator::Bookings.new(tenant.legacy).perform
               end

      @stats = [] if @stats.nil?
    end

    private

    attr_reader :tenant

    def quotation_tool?(tenant)
      tenant.scope.content['closed_quotation_tool'] || tenant.scope.content['open_quotation_tool']
    end
  end
end
