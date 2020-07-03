# frozen_string_literal: true

module Api
  class OrganizationSerializer < Api::ApplicationSerializer
    attribute :slug
    attribute :name do |object|
      object.theme.name
    end
  end
end
