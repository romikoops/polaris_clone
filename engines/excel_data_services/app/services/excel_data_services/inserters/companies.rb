# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Companies < ExcelDataServices::Inserters::Base
      def perform
        data.each do |params|
          update_or_create_company(params)
        end

        stats
      end

      private

      def update_or_create_company(params)
        company = ::Companies::Company.find_or_initialize_by(
          organization_id: @organization.id,
          name: params[:name],
          email: params[:email]
        )
        add_stats(company, params[:row_nr])

        company.update(
          vat_number: params[:vat_number],
          phone: params[:phone],
          email: params[:email],
          payment_terms: params[:payment_terms],
          address_id: params[:address_id]
        )
      end
    end
  end
end
