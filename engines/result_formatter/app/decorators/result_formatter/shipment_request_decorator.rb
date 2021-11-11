# frozen_string_literal: true

module ResultFormatter
  class ShipmentRequestDecorator < ApplicationDecorator
    delegate_all

    decorates_association :company, with: CompanyDecorator
    decorates_association :client, with: ClientDecorator
    decorates_association :result, with: ResultDecorator

    delegate :query, to: :result

    def commercial_value_format
      commercial_value.format(rounded_infinite_precision: true, symbol: "#{commercial_value_currency} ")
    end

    def total_format
      result.total.format(rounded_infinite_precision: true, symbol: "#{result.query.currency} ")
    end

    def cargo_units
      @cargo_units ||= result.query.cargo_units.map { |cargo_unit| CargoDecorator.new(cargo_unit) }
    end

    def commodity_infos
      @commodity_infos ||= cargo_units.flat_map(&:commodity_infos)
    end
  end
end
