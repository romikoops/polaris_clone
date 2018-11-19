# frozen_string_literal: true

require 'bigdecimal'
require 'json-schema'
require 'rule_engine'

require 'charge_calculator/models/base'
require 'charge_calculator/models/cargo_unit'
require 'charge_calculator/models/price'
require 'charge_calculator/models/pricing'
require 'charge_calculator/models/rate'

require 'charge_calculator/reducers/base'
require 'charge_calculator/reducers/first'
require 'charge_calculator/reducers/max'
require 'charge_calculator/reducers/sum'
require 'charge_calculator/reducers'

require 'charge_calculator/calculators/base'
require 'charge_calculator/calculators/bill_of_lading'
require 'charge_calculator/calculators/chargeable_payload'
require 'charge_calculator/calculators/flat'
require 'charge_calculator/calculators/payload'
require 'charge_calculator/calculators/payload_unit_100_kg'
require 'charge_calculator/calculators/payload_unit_ton'
require 'charge_calculator/calculators/volume'
require 'charge_calculator/calculators/weight_measure'
require 'charge_calculator/calculators'

require 'charge_calculator/contexts/base'
require 'charge_calculator/contexts/cargo_unit'
require 'charge_calculator/contexts/shipment'

require 'charge_calculator/main'

module ChargeCalculator
  def self.calculate(shipment_params:, pricings:)
    Main.new(shipment_params: shipment_params, pricings: pricings).price
  end
end
