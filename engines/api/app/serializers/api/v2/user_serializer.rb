# frozen_string_literal: true

module Api
  module V2
    class UserSerializer < Api::ApplicationSerializer
      attributes %i[
        id
        email
        first_name
        last_name
        phone
        locale
        language
        currency
        last_activity_at
        auth_methods
        saml_integrations
      ]
    end
  end
end
