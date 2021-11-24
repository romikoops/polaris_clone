# frozen_string_literal: true

module Api
  module V2
    class UserSerializer < Api::ApplicationSerializer
      attributes %i[id first_name auth_methods saml_integrations]
    end
  end
end
