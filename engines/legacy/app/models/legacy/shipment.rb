module Legacy
  class Shipment < ApplicationRecord
    self.table_name = 'shipments'
    LOAD_TYPES = %w(cargo_item container).freeze
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint(8)        not null, primary key
#  user_id                             :integer
#  uuid                                :string
#  imc_reference                       :string
#  status                              :string
#  load_type                           :string
#  planned_pickup_date                 :datetime
#  has_pre_carriage                    :boolean
#  has_on_carriage                     :boolean
#  cargo_notes                         :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  tenant_id                           :integer
#  planned_eta                         :datetime
#  planned_etd                         :datetime
#  itinerary_id                        :integer
#  trucking                            :jsonb
#  customs_credit                      :boolean          default(FALSE)
#  total_goods_value                   :jsonb
#  trip_id                             :integer
#  eori                                :string
#  direction                           :string
#  notes                               :string
#  origin_hub_id                       :integer
#  destination_hub_id                  :integer
#  booking_placed_at                   :datetime
#  insurance                           :jsonb
#  customs                             :jsonb
#  transport_category_id               :bigint(8)
#  incoterm_id                         :integer
#  closing_date                        :datetime
#  incoterm_text                       :string
#  origin_nexus_id                     :integer
#  destination_nexus_id                :integer
#  planned_origin_drop_off_date        :datetime
#  quotation_id                        :integer
#  planned_delivery_date               :datetime
#  planned_destination_collection_date :datetime
#  desired_start_date                  :datetime
#
