# frozen_string_literal: true

module Api
  class UserSerializer < ActiveModel::Serializer
    attributes %i[id email first_name last_name company_name phone state]
    delegate :first_name, to: :profile
    delegate :last_name, to: :profile
    delegate :phone, to: :profile
    delegate :company_name, to: :profile

    def state
      object.activation_state
    end

    def profile
      Profiles::Profile.find_by(user_id: object.id)
    end
  end
end
