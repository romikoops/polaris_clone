# frozen_string_literal: true

module Legacy
  class CustomValidations
    def self.inclusion(klass, attribute, array)
      klass.validates attribute,
                      inclusion: {
                        in: array,
                        message: "must be included in #{array}"
                      },
                      allow_nil: true
    end

    def self.cargo_item_max_dimensions(klass, mode_of_transport = nil)
      klass::DIMENSIONS.each do |dimension|
        klass.validates dimension,
                        presence: true,
                        numericality: {
                          greater_than_or_equal_to: 0,
                          less_than_or_equal_to: lambda { |obj|
                            mot = mode_of_transport || obj.shipment.itinerary.try(:mode_of_transport)
                            CustomValidations.max_dimension(tenant_id: obj.tenant.id, mode_of_transport: mode_of_transport, dimension: dimension)
                          }
                        },
                        if: lambda { |obj|
                          mot = mode_of_transport || obj.shipment.itinerary.try(:mode_of_transport)
                          mot && CustomValidations.max_dimension(tenant_id: obj.tenant.id, mode_of_transport: mode_of_transport, dimension: dimension)
                        }
      end
      klass
    end

    def self.max_dimension(tenant_id:, mode_of_transport:, dimension:)
      bundle = MaxDimensionsBundle.find_by(tenant_id: tenant_id, mode_of_transport: mode_of_transport, aggregate: false)
      bundle.present? ? bundle[dimension] : nil
    end
  end
end
