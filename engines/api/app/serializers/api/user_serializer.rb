# frozen_string_literal: true

module Api
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :email, :state, :tenant_id

    def state
      object.activation_state
    end
  end
end
