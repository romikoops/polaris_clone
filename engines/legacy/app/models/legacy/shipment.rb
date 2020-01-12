# frozen_string_literal: true

module Legacy
  class Shipment < ApplicationRecord
    self.table_name = 'shipments'

    LOAD_TYPES = %w(cargo_item container).freeze

    belongs_to :user, class_name: 'Legacy::User'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :origin_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :destination_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :itinerary, optional: true, class_name: 'Legacy::Itinerary'
    belongs_to :transport_category, optional: true, class_name: 'Legacy::TransportCategory'
    belongs_to :trip, optional: true, class_name: 'Legacy::Trip'

    has_many :shipment_contacts, class_name: 'Legacy::ShipmentContact'
    has_many :containers, class_name: 'Legacy::Container'
    has_many :cargo_items, class_name: 'Legacy::CargoItem'
    has_many :cargo_item_types, through: :cargo_items, class_name: 'Legacy::CargoItemType'
    has_one :aggregated_cargo, class_name: 'Legacy::AggregatedCargo'
    has_many :charge_breakdowns, class_name: 'Legacy::ChargeBreakdown' do
      def to_schedules_charges
        reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
      end
    end

    validates_with Legacy::MaxAggregateDimensionsValidator
    validates_with Legacy::HubNexusMatchValidator

    before_validation :generate_imc_reference,
                      :set_default_trucking, :set_tenant,
                      on: :create
    before_validation :update_carriage_properties!, :set_default_destination_dates

    delegate :mode_of_transport, to: :itinerary, allow_nil: true

    has_many :charge_breakdowns, class_name: 'Legacy::ChargeBreakdown' do
      def to_schedules_charges
        reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
      end
    end

    before_validation :generate_imc_reference,
                      :set_default_trucking, :set_tenant,
                      on: :create
    before_validation :update_carriage_properties!, :set_default_destination_dates

    def set_trucking_chargeable_weight(target, weight)
      trucking[target]['chargeable_weight'] = weight
    end

    def cargo_classes
      if aggregated_cargo
        ['lcl']
      else
        cargo_units.pluck(:cargo_class).uniq
      end
    end

    def cargo_units
      send("#{load_type}s")
    end

    def cargo_units=(value)
      send("#{load_type}s=", value)
    end

    def lcl?
      load_type == 'cargo_item'
    end

    def fcl?
      load_type == 'container'
    end

    def has_on_carriage?
      has_on_carriage
    end

    def has_pre_carriage?
      has_pre_carriage
    end

    def has_carriage?(carriage)
      send("has_#{carriage}_carriage?")
    end

    def valid_for_itinerary?(itinerary_id)
      current_itinerary = itinerary

      self.itinerary_id = itinerary_id
      return_bool = valid?

      self.itinerary = current_itinerary

      return_bool
    end


    def pickup_address
      Legacy::Address.where(id: trucking.dig('pre_carriage', 'address_id')).first
    end

    def delivery_address
      Legacy::Address.where(id: trucking.dig('on_carriage', 'address_id')).first
    end

    def valid_until(target_trip)
      return nil if target_trip.nil? || target_trip.itinerary.nil?

      charge_breakdowns.find_by(trip_id: target_trip.id)&.valid_until
    end

    def service_level
      trip&.tenant_vehicle&.name
    end

    def carrier
      trip&.tenant_vehicle&.carrier&.name
    end

    def vessel_name
      trip&.vessel
    end

    def voyage_code
      trip&.voyage_code
    end

    private

    def update_carriage_properties!
      %w(on_carriage pre_carriage).each do |carriage|
        self["has_#{carriage}"] = !trucking.dig(carriage, 'truck_type').blank?
      end
    end

    def set_default_destination_dates
      return unless planned_eta && planned_etd && closing_date

      set_default_planned_destination_collection_date unless has_on_carriage?
      set_default_planned_delivery_date if has_on_carriage?
    end

    def set_default_planned_destination_collection_date
      self.planned_destination_collection_date ||= planned_eta + 1.week
    end

    def set_default_planned_delivery_date
      self.planned_delivery_date ||= planned_eta + 10.days
    end

    def generate_imc_reference
      now = DateTime.now
      day_of_the_year = now.strftime('%d%m')
      hour_as_letter = ('A'..'Z').to_a[now.hour - 1]
      year = now.year.to_s[-2..-1]
      first_part = day_of_the_year + hour_as_letter + year
      last_shipment_in_this_hour = Shipment.where('imc_reference LIKE ?', first_part + '%').last
      if last_shipment_in_this_hour
        last_serial_number = last_shipment_in_this_hour.imc_reference[first_part.length..-1].to_i
        new_serial_number = last_serial_number + 1
        serial_code = new_serial_number.to_s.rjust(5, '0')
      else
        serial_code = '1'.rjust(5, '0')
      end

      self.imc_reference = first_part + serial_code
    end

    def find_contacts(type)
      Contact.find_by_sql("
        SELECT * FROM contacts
        JOIN  shipment_contacts ON shipment_contacts.contact_id   = contacts.id
        JOIN  shipments         ON shipments.id                   = shipment_contacts.shipment_id
        WHERE shipments.id = #{id}
        AND   shipment_contacts.contact_type = '#{type}'
      ")
    end

    def planned_pickup_date_is_a_datetime?
      return if planned_pickup_date.nil?

      errors.add(:planned_pickup_date, 'must be a DateTime') unless planned_pickup_date.is_a?(ActiveSupport::TimeWithZone)
    end

    def desired_start_date_is_a_datetime?
      return if desired_start_date.nil?

      errors.add(:desired_start_date, 'must be a DateTime') unless desired_start_date.is_a?(ActiveSupport::TimeWithZone)
    end

    def set_default_trucking
      self.trucking ||= { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } }
    end

    def set_tenant
      self.tenant_id ||= user&.tenant_id
    end

    def user_tenant_match
      return if user.nil? || tenant_id == user.tenant_id

      errors.add(:user, "tenant_id does not match the shipment's tenant_id")
    end

    def itinerary_trip_match
      return if trip.nil? || trip.itinerary_id == itinerary_id

      errors.add(:itinerary, "id does not match the trips's itinerary_id")
    end

  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
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
#  transport_category_id               :bigint
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
