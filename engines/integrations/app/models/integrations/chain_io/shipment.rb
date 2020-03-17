# frozen_string_literal: true

module Integrations
  module ChainIo
    class Shipment < Legacy::Shipment
      def pickup_address
        read_attribute(:pickup_address) || ''
      end

      def delivery_address
        read_attribute(:delivery_address) || ''
      end

      def selected_day
        read_attribute(:selected_day) || ''
      end

      def dimensional_weight
        tonage_per_cbm = Legacy::CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER[mode_of_transport.to_sym]

        cargo_items.sum do |cargo_item|
          volume = cargo_item.dimension_x * cargo_item.dimension_y * cargo_item.dimension_z / 1_000_000.0
          volume * tonage_per_cbm * 1000
        end
      end

      def chargeable_weight
        cargo_items.pluck(:chargeable_weight).sum
      end
    end
  end
end
