# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class Employees < Base
      def perform
        data.each do |params|
          update_or_create_employee(params)
        end

        stats
      end

      private

      def update_or_create_employee(params)
        legacy_user = ::User.find_by(email: params[:email], tenant: @tenant)
        legacy_user ||= ::User.create!(
          first_name: params[:first_name],
          last_name: params[:last_name],
          password: params[:password],
          tenant_id: @tenant.id,
          email: params[:email],
          phone: params[:phone],
          vat_number: params[:vat_number],
          role_id: Role.find_by(name: 'shipper'),
          sandbox: @sandbox
        )
        tenants_user = Tenants::User.find_by(legacy_id: legacy_user)
        tenants_user.update(company: params[:company])
        add_stats(tenants_user)

      end
    end
  end
end
