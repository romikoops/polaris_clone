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
          volume = cargo_item.width * cargo_item.length * cargo_item.height / 1_000_000.0
          volume * tonage_per_cbm * 1000
        end
      end

      def chargeable_weight
        cargo_items.pluck(:chargeable_weight).sum
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
#  booking_placed_at                   :datetime
#  cargo_notes                         :string
#  closing_date                        :datetime
#  customs                             :jsonb
#  customs_credit                      :boolean          default(FALSE)
#  deleted_at                          :datetime
#  desired_start_date                  :datetime
#  direction                           :string
#  eori                                :string
#  has_on_carriage                     :boolean
#  has_pre_carriage                    :boolean
#  imc_reference                       :string
#  incoterm_text                       :string
#  insurance                           :jsonb
#  load_type                           :string
#  meta                                :jsonb
#  notes                               :string
#  planned_delivery_date               :datetime
#  planned_destination_collection_date :datetime
#  planned_eta                         :datetime
#  planned_etd                         :datetime
#  planned_origin_drop_off_date        :datetime
#  planned_pickup_date                 :datetime
#  status                              :string
#  total_goods_value                   :jsonb
#  trucking                            :jsonb
#  uuid                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  destination_hub_id                  :integer
#  destination_nexus_id                :integer
#  incoterm_id                         :integer
#  itinerary_id                        :integer
#  origin_hub_id                       :integer
#  origin_nexus_id                     :integer
#  quotation_id                        :integer
#  sandbox_id                          :uuid
#  tenant_id                           :integer
#  tender_id                           :uuid
#  trip_id                             :integer
#  user_id                             :integer
#
# Indexes
#
#  index_shipments_on_sandbox_id  (sandbox_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tenant_id   (tenant_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tender_id   (tender_id)
#
