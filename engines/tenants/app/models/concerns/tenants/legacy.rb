# frozen_string_literal: true

module Tenants
  module Legacy
    extend ActiveSupport::Concern

    module ClassMethods
      def create_from_legacy(source)
        create(__legacy_params(source))
      end

      def __legacy_params(model)
        case model
        when ::Legacy::User
          __legacy_user_params(model)
        when ::Legacy::Tenant
          __legacy_tenant_params(model)
        end
      end

      def __legacy_user_params(user)
        {
          email: user.email,
          crypted_password: user.encrypted_password,
          salt: nil,
          legacy_id: user.id,
          tenant_id: Tenants::Tenant.find_by(legacy_id: user.tenant_id)&.id,
          activation_state: 'active',
          skip_activation_needed_email: true
        }
      end

      def __legacy_tenant_params(tenant)
        {
          slug: tenant.__subdomain,
          legacy_id: tenant.id
        }
      end
    end

    def update_from_legacy(source)
      update_attributes(self.class.__legacy_params(source))
    end
  end
end
