# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class Companies < Base
      def perform
        data.each do |params|
          update_or_create_company(params)
        end

        stats
      end

      private

      def update_or_create_company(params)
        company = Tenants::Company.find_or_initialize_by(
          tenant_id: Tenants::Tenant.find_by(legacy_id: @tenant.id).id,
          name: params[:name],
          vat_number: params[:vat_number],
          external_id: params[:external_id],
          phone: params[:phone],
          email: params[:email],
          address_id: params[:address_id]
        )
        add_stats(company)
        company.save!
      end
    end
  end
end
