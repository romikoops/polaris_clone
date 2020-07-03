# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < Api::ApplicationSerializer
      attributes %i[email organization_id first_name last_name phone company_name]

      attribute :role do |user|
        user.membership&.role
      end
    end
  end
end
