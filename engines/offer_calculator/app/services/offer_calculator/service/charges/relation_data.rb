# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class RelationData
        FRAME_KEYS = %w[
          cbm_ratio tenant_vehicle_id cargo_class load_type origin_hub_id destination_hub_id
          direction margin_type effective_date expiration_date vm_ratio context_id rate_basis
          range_min range_max range_unit charge_category_id itinerary_id code rate base currency
          section organization_id load_meterage_ratio
          load_meterage_stackable_type load_meterage_non_stackable_type load_meterage_hard_limit
          load_meterage_stackable_limit load_meterage_non_stackable_limit km truck_type carrier_lock carrier_id
          source_id source_type min max metadata
        ].freeze

        attr_reader :relation, :period, :start_date, :end_date

        def initialize(relation:, period:)
          @relation = relation
          @start_date = period.first.to_date
          @end_date = period.last.to_date
        end

        def frame
          @frame ||= OfferCalculator::Service::Charges::Support::DateLimiter.new(
            frame: rate_frame_data, start_date: start_date, end_date: end_date
          ).perform
        end

        private

        def rate_frame_data
          @rate_frame_data ||= relation.inject(base_frame) do |base, record|
            base.concat(record_data_class.new(record: record).perform)[FRAME_KEYS]
          end
        end

        def record_data_class
          "OfferCalculator::Service::Charges::RecordData::#{source_type}".constantize
        end

        def source_type
          relation.klass.name.demodulize
        end

        def base_frame
          @base_frame ||= Rover::DataFrame.new(FRAME_KEYS.zip([].cycle).to_h)
        end
      end
    end
  end
end
