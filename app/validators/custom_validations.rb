# frozen_string_literal: true

module CustomValidations
  def self.inclusion(klass, attribute, array)
    klass.validates attribute,
      inclusion: {
        in:      array,
        message: "must be included in #{array.log_format}"
      },
      allow_nil: true
  end

  def self.cargo_item_max_dimensions(klass, itinerary_arg = nil)
    klass::DIMENSIONS.each do |dimension|
      klass.validates dimension,
        presence: true,
        numericality: {
          greater_than_or_equal_to: 0,
          less_than_or_equal_to: -> obj {
            itinerary = itinerary_arg || obj.shipment.itinerary
            obj.tenant.max_dimensions.dig(itinerary.mode_of_transport.to_sym, dimension)
          }
        },
        if: -> obj {
          itinerary = itinerary_arg || obj.shipment.itinerary
          (itinerary_arg || obj.shipment.itinerary) &&
            obj.tenant.max_dimensions.dig(itinerary.mode_of_transport.to_sym, dimension)
        }
    end
    klass
  end
end
