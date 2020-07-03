# frozen_string_literal: true

module Api
  module V1
    class OrganizationDecorator < Draper::Decorator
      decorates "Organizations::Organization"

      delegate_all
    end
  end
end
