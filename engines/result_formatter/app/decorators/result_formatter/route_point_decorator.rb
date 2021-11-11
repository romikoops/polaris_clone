# frozen_string_literal: true

module ResultFormatter
  class RoutePointDecorator < Draper::Decorator
    decorates "Journey::RoutePoint"

    delegate_all

    def description
      locode.present? ? "#{name} (#{locode})" : name
    end

    def latitude
      coordinates.y
    end

    def longitude
      coordinates.x
    end
  end
end
