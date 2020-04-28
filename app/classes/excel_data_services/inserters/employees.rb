# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class Employees < ExcelDataServices::Inserters::Base
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
          password: params[:password],
          tenant_id: @tenant.id,
          email: params[:email],
          vat_number: params[:vat_number],
          company_number: params[:company_number],
          role_id: Role.find_by(name: 'shipper'),
          sandbox: @sandbox
        )
        tenants_user = Tenants::User.find_by(legacy_id: legacy_user)
        tenants_user.update(company: params[:company])
        update_or_create_employee_profile(employee: tenants_user, params: params)
        add_stats(tenants_user, params[:row_nr], true)
      end

      def update_or_create_employee_profile(employee:, params:)
        Profiles::ProfileService.create_or_update_profile(user: employee,
                                                          first_name: params[:first_name],
                                                          last_name: params[:last_name],
                                                          phone: params[:phone])
      end
    end
  end
end
