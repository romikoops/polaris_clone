# frozen_string_literal: true

module Api
  module V1
    class UserSerializer < ActiveModel::Serializer
      attributes %i[email tenant_id first_name last_name phone company_name]
    end
  end
end
