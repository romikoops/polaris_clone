# frozen_string_literal: true

module CustomValidations
  def self.inclusion(klass, attribute, array)
    klass.validates attribute,
                    inclusion: {
                      in: array,
                      message: "must be included in #{array.log_format}"
                    },
                    allow_nil: true
  end

  def self.cargo_item_max_dimensions(klass, mot, max_dimensions, itinerary_arg = nil)
    max_dimensions.each do |attribute, max_dimension|
      klass.validates attribute,
                      presence: true,
                      numericality: {
                        greater_than_or_equal_to: 0,
                        less_than_or_equal_to: max_dimension
                      },
                      if: ->(obj) {
                        itinerary = itinerary_arg || obj.shipment.itinerary
                        max_dimension > 0 &&
                          ((mot == :general) || (mot == (itinerary&.mode_of_transport&.to_sym)))
                      }
    end
    klass
  end
end
