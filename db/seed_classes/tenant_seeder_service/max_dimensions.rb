# frozen_string_literal: true

module TenantSeederService
  class MaxDimensions
    def initialize(tenant:, other_data:)
      @tenant = tenant
      @other_data = other_data
    end

    def update_default_max_dimensions!
      modes_of_transport = %i(general)
      modes_of_transport += %i(air ocean rail).select do |mot|
        tenant.mode_of_transport_in_scope? mot
      end
      MaxDimensionsBundle.create_defaults_for(
        tenant,
        modes_of_transport: modes_of_transport,
        all: true # Creates for aggregate and unit
      )
    end

    def update_max_dimensions!
      update_default_max_dimensions!

      update_max_unit_dimensions! unless other_data[:max_dimensions].nil?
      update_max_aggregate_dimensions! unless other_data[:max_aggregate_dimensions].nil?
    end

    private

    attr_reader :tenant, :other_data

    def update_max_unit_dimensions!
      update_tenant_specific_dimensions(
        max_dimensions_data: other_data[:max_dimensions],
        aggregate: false
      )
    end

    def update_max_aggregate_dimensions!
      update_tenant_specific_dimensions(
        max_dimensions_data: other_data[:max_aggregate_dimensions],
        aggregate: true
      )
    end

    def update_tenant_specific_dimensions(max_dimensions_data:, aggregate:)
      max_dimensions_data.each do |mode_of_transport, max_dimensions|
        scopping_attributes = {
          mode_of_transport: mode_of_transport,
          tenant: tenant,
          aggregate: aggregate
        }

        max_dimensions_bundle = MaxDimensionsBundle.find_by(scopping_attributes)
        max_dimensions_bundle ||= MaxDimensionsBundle.new(scopping_attributes)

        max_dimensions_bundle.update!(max_dimensions)
      end
    end
  end
end
