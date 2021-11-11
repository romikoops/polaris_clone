# frozen_string_literal: true

module ResultFormatter
  class RouteSectionDecorator < ApplicationDecorator
    decorates "Journey::RouteSection"
    decorates_association :result, with: ResultDecorator
    decorates_association :from, with: RoutePointDecorator
    decorates_association :to, with: RoutePointDecorator
    delegate_all

    def section_string
      charge_category_code = case mode_of_transport
                             when "carriage"
                               "trucking_#{order.zero? ? 'pre' : 'on'}"
                             when "relay"
                               (order <= 1 ? "export" : "import").to_s
                             else
                               "cargo"
      end

      Legacy::ChargeCategory.find_by(code: charge_category_code, organization: result.query.organization).name
    end

    def transit_time
      scope.dig("voyage_info", "transit_time").present? && super
    end
  end
end
