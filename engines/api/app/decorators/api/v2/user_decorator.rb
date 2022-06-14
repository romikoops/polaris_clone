# frozen_string_literal: true

module Api
  module V2
    class UserDecorator < ApplicationDecorator
      decorates "Users::User"
      delegate_all
      delegate :first_name, :last_name, :phone, to: :profile, allow_nil: true
      delegate :locale, :language, :currency, to: :settings, allow_nil: true

      def saml_integrations
        []
      end

      def saml_enabled?
        organizations.joins(:saml_metadata).present?
      end

      def auth_methods
        ["password", saml_enabled? ? "saml" : nil].compact
      end
    end
  end
end
