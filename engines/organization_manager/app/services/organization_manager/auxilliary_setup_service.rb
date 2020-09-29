# frozen_string_literal: true

module OrganizationManager
  class AuxilliarySetupService
    def initialize(organization:)
      @organization = organization
    end

    def perform
      max_dimensions
      cargo_item_type
    end

    private

    attr_reader :organization

    def max_dimensions
      cargo_classes.map do |cargo_class|
        Legacy::MaxDimensionsBundle.create(
          width: 1000,
          length: 1000,
          height: 1000,
          payload_in_kg: 21_770.0,
          chargeable_weight: 21_770.0,
          volume: 1_000.0,
          cargo_class: cargo_class,
          mode_of_transport: "general",
          organization: organization
        )
      end
    end

    def cargo_item_type
      Legacy::TenantCargoItemType.create(cargo_item_type: pallet_type, organization: organization)
    end

    def cargo_classes
      Legacy::Container::CARGO_CLASSES + ["lcl"]
    end

    def pallet_type
      @pallet_type ||= Legacy::CargoItemType.find_by(description: "Pallet")
    end
  end
end
