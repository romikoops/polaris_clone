# frozen_string_literal: true

module Notifications
  class ResultDecorator < ResultFormatter::ResultDecorator
    delegate_all
    delegate :currency, to: :query

    def total
      super.format(rounded_infinite_precision: true, symbol: "#{currency} ")
    end

    def routing
      [
        origin_route_point.name,
        destination_route_point.name
      ].join(" - ")
    end
  end
end
