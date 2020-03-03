# frozen_string_literal: true

module Api
  class TenantSerializer < ActiveModel::Serializer
    attributes :slug
  end
end
