# frozen_string_literal: true

module Legacy
  class UserSerializer < ActiveModel::Serializer
    attributes %i(id email tenant_id first_name last_name company_name phone)
  end
end
