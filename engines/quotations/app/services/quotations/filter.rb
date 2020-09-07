# frozen_string_literal: true

module Quotations
  class Filter
    def initialize(organization:, start_date:, end_date:)
      @organization = organization
      @start_date = start_date
      @end_date = end_date
    end

    def perform
      quotations = Quotations::Quotation.where(organization: organization)
      quotations = quotations.where("selected_date >= ?", start_date) if start_date.present?
      quotations = quotations.where("selected_date <= ?", end_date) if end_date.present?
      quotations.order(:selected_date)
    end

    private

    attr_reader :organization, :start_date, :end_date
  end
end
