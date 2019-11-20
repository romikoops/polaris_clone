# frozen_string_literal: true

module Api
  class PortSerializer < ActiveModel::Serializer
    type 'ports'

    attributes :id, :name
  end
end
