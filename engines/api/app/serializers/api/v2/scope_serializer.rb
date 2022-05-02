# frozen_string_literal: true

module Api
  module V2
    class ScopeSerializer < Api::ApplicationSerializer
      attributes %i[links id auth_methods loginSamlText loginMandatory]

      attribute :registrationProhibited, &:closed_registration
      attribute :loginMandatory, &:closed_shop
      attribute :loginSamlText, &:saml_text
    end
  end
end
