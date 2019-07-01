module Legacy
  class Shipment < ApplicationRecord
    self.table_name = 'shipments'
    LOAD_TYPES = %w(cargo_item container).freeze
    belongs_to :user, class_name: 'Legacy::User'
    # belongs_to :quotation, optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    # has_many :documents
    # has_many :shipment_contacts
    # has_many :contacts, through: :shipment_contacts
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :origin_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :destination_hub, class_name: 'Legacy::Hub', optional: true
    # belongs_to :route, optional: true
    belongs_to :itinerary, optional: true, class_name: 'Legacy::Shipment'
    belongs_to :trip, optional: true, class_name: 'Legacy::Trip'
    # belongs_to :transport_category, optional: true
    has_many :containers, class_name: 'Legacy::Container'
    has_many :cargo_items, class_name: 'Legacy::CargoItem'
    has_many :cargo_item_types, through: :cargo_items, class_name: 'Legacy::CargoItemType'
    has_one :aggregated_cargo, class_name: 'Legacy::AggregatedCargo'
    # has_many :conversations
    # has_many :messages, through: :conversations
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
#  meta                                :jsonb
#  sandbox_id                          :uuid
#
