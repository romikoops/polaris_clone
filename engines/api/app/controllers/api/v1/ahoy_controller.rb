# frozen_string_literal: true

module Api
  module V1
    class AhoyController < ApiController
      skip_before_action :doorkeeper_authorize!, only: :settings

      def settings
        tenant = Tenants::Tenant.find_by(id: params[:id])

        return render(json: {}, status: :not_found) unless tenant

        scope = Tenants::ScopeService.new(tenant: tenant, sandbox: @sandbox).fetch

        result = {
          endpoint: Tenants::Domain.find_by(tenant_id: tenant, default: true).domain,
          modes_of_transport: normalize_modes_of_transport!(scope[:modes_of_transport]),
          pre_carriage: scope.dig(:carriage_options, :pre_carriage, :export) != 'disabled',
          on_carriage: scope.dig(:carriage_options, :on_carriage, :export) != 'disabled'
        }

        render json: result
      end

      private

      def normalize_modes_of_transport! (modes_of_transport)
        keys_mapping = { 'container' => 'fcl', 'cargo_item' => 'lcl' }

        modes_of_transport.each_value do |value|
          value.deep_transform_keys! { |k| keys_mapping[k] }
        end
      end
    end
  end
end
