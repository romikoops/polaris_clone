# frozen_string_literal: true

module ResultFormatter
  class RoutePointDecorator < Draper::Decorator
    decorates "Journey::RoutePoint"

    delegate_all

    def description
      [
        name_and_terminal,
        locode && "(#{locode})"
      ].compact.join(" ")
    end

    def name_and_terminal
      [
        name,
        terminal && "- #{terminal}"
      ].compact.join(" ")
    end

    def latitude
      coordinates.y
    end

    def longitude
      coordinates.x
    end
  end
end
