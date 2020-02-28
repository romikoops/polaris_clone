# frozen_string_literal: true

require_dependency 'admiralty_reports/application_controller'

module AdmiraltyReports
  class StatsController < ApplicationController
    def download
      @tenants = Tenant.order(:subdomain)
      @stats = stats
      @raw_request_data = raw_request_data
      excel_package = ExcelGenerator.generate(raw_request_data: @raw_request_data).process_excel_file
      send_data excel_package.to_stream.read, type: 'application/xlsx', filename: 'StatsOverview.xlsx'
    end

    private

    def stats
      @tenants.map { |tenant| Stats.new(tenant: tenant, month: filter_params[:month], year: filter_params[:year]) }
    end

    def raw_request_data
      @stats.flat_map(&:raw_request_data)
    end

    def filter_params
      params.permit(:month, :year)
    end
  end
end
