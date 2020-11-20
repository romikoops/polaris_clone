# frozen_string_literal: true

require_dependency "admiralty_reports/application_controller"

module AdmiraltyReports
  class ReportsController < ApplicationController
    MONTH_LOOKUP = Date::MONTHNAMES[1..12].zip(1..12).freeze

    def index
      @organizations = Organizations::Organization.order(:slug).all
      first_year = Legacy::Shipment.order(:created_at).first&.created_at&.year || Time.zone.now.year
      @possible_years = (first_year..Time.zone.now.year).to_a
    end

    def show
      @organization = Organizations::Organization.find(params[:id])
      @month = filter_params[:month]
      @year = filter_params[:year]
      @stats = Stats.new(organization: @organization, month: @month, year: @year)
    end

    private

    def filter_params
      params.permit(:month, :year)
    end
  end
end
