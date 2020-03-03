# frozen_string_literal: true

module Api
  class TenantsGroupSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
