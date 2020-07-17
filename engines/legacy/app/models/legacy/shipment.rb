# frozen_string_literal: true

module Legacy
  class Shipment < ApplicationRecord
    include PgSearch::Model

    self.table_name = 'shipments'
    STATUSES = %w[
      booking_process_started
      requested_by_unconfirmed_account
      requested
      pending
      confirmed
      declined
      ignored
      finished
      quoted
      archived
      in_progress
    ].freeze
    LOAD_TYPES = %w[cargo_item container].freeze
    DIRECTIONS = %w[import export].freeze

    acts_as_paranoid

    belongs_to :user, -> { with_deleted }, class_name: 'Organizations::User', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :origin_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :destination_nexus, class_name: 'Legacy::Nexus', optional: true
    belongs_to :origin_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :destination_hub, class_name: 'Legacy::Hub', optional: true
    belongs_to :itinerary, optional: true, class_name: 'Legacy::Itinerary'
    belongs_to :trip, optional: true, class_name: 'Legacy::Trip'
    belongs_to :quotation, optional: true
    has_many :shipment_contacts, class_name: 'Legacy::ShipmentContact'
    has_many :containers, class_name: 'Legacy::Container'
    has_many :cargo_items, class_name: 'Legacy::CargoItem'
    has_many :cargo_item_types, through: :cargo_items, class_name: 'Legacy::CargoItemType'
    has_one :aggregated_cargo, class_name: 'Legacy::AggregatedCargo'
    has_many :files, class_name: 'Legacy::File'
    has_many :charge_breakdowns, class_name: 'Legacy::ChargeBreakdown' do
      def to_schedules_charges
        reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
      end
    end

    has_many :documents # DEPRECATED
    deprecate documents: 'Migrated to Legacy::File'

     # Scopes
    scope :has_pre_carriage, -> { where(has_pre_carriage: true) }
    scope :has_on_carriage,  -> { where(has_on_carriage:  true) }
    scope :order_booking_desc, -> { order(booking_placed_at: :desc) }
    scope :requested, -> { where(status: %w(requested requested_by_unconfirmed_account)) }
    scope :requested_by_unconfirmed_account, -> { where(status: 'requested_by_unconfirmed_account') }
    scope :open, -> { where(status: %w(in_progress confirmed)) }
    scope :rejected, -> { where(status: %w(ignored declined)) }
    scope :archived, -> { where(status: 'archived') }
    scope :finished, -> { where(status: 'finished') }
    scope :quoted, -> { where(status: 'quoted') }
    scope :excluding_tests, -> { where.not(billing: :test) }
    %i(ocean air rail).each do |mot|
      scope mot, -> { joins(:itinerary).where(Itinerary.arel_table[:mode_of_transport].eq(mot)) }
    end

    scope :modes_of_transport, lambda { |*mots|
      mots[1..-1].reduce(send(mots.first)) do |result, mot|
        result.or(send(mot))
      end
    }

    enum billing: {external: 0, internal: 1, test: 2}

    validates_with Legacy::MaxAggregateDimensionsValidator
    validates_with Legacy::HubNexusMatchValidator

    # Validations
    { status: STATUSES, load_type: LOAD_TYPES, direction: DIRECTIONS }.each do |attribute, array|
      validates attribute.to_sym,
                inclusion: {
                  in: array,
                  message: "must be included in #{array}"
                },
                allow_nil: true
    end

    before_validation :generate_imc_reference,
                      :set_default_trucking,
                      :set_organization,
                      :set_distinct_id,
                      on: :create
    before_validation :update_carriage_properties!, :set_default_destination_dates

    delegate :mode_of_transport, to: :itinerary, allow_nil: true

    pg_search_scope :index_search,
    against: %i(imc_reference),
    associated_against: {
      user: %i[email],
      origin_hub: %i(name),
      destination_hub: %i(name)
    },
    using: {
      tsearch: { prefix: true }
    }

    scope :user_name, lambda { |query|
      user_ids = Profiles::Profile
        .where('first_name ILIKE ? OR last_name ILIKE ?', "%#{query}%", "%#{query}%")
        .pluck(:user_id)
      where(user_id: user_ids)
    }

    scope :company_name, lambda { |query|
      user_ids = Profiles::Profile.where('company_name ILIKE ? ', "%#{query}%").pluck(:user_id)
      where(user_id: user_ids)
    }

    scope :reference_number, lambda { |query|
      where('imc_reference ILIKE ? ', "%#{query}%")
    }

    scope :hub_names, lambda { |query|
      hub_ids = Hub.where('name ILIKE ?', "%#{query}%").ids
      where('origin_hub_id IN (?) OR destination_hub_id IN (?)', hub_ids, hub_ids)
    }

    scope :user_search, lambda { |query|
      user_name(query).or(Shipment.company_name(query)).or(Shipment.reference_number(query))
        .or(Shipment.hub_names(query))
    }

    has_many :charge_breakdowns, class_name: 'Legacy::ChargeBreakdown' do
      def to_schedules_charges
        reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
      end
    end

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

    def selected_offer(args)
      charge_breakdowns.selected.to_nested_hash(args)
    end

    def shipper
      find_contacts('shipper').first
    end

    def consignee
      find_contacts('consignee').first
    end

    def notifyees
      find_contacts('notifyee')
    end

    def etd
      planned_etd
    end

    def eta
      planned_eta
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

    def total_price(hidden_total: false)
      return if trip_id.nil? || hidden_total

      price = charge_breakdowns.find_by(trip_id: trip_id).charge('grand_total').price

      { value: price.value, currency: price.currency }
    end

    def edited_total
      return if trip_id.nil?

      price = charge_breakdowns.where(trip_id: trip_id).first.charge('grand_total').edited_price

      return nil if price.nil?

      { value: price.value, currency: price.currency }
    end

    def cargo_count
      if aggregated_cargo
        1
      else
        cargo_units.reduce(0) { |sum, unit| sum + unit.quantity }
      end
    end

    def pickup_address_with_country
      pickup_address.as_json(include: :country)
    end

    def delivery_address_with_country
      delivery_address.as_json(include: :country)
    end

    def client_name
      shipment_user_profile.full_name
    end

    delegate :company_name, to: :shipment_user_profile

    def shipment_user_profile
      profile = Profiles::Profile.find_by(user_id: user_id)
      Profiles::ProfileDecorator.new(profile)
    end

    def with_address_options_json(options = {})
      as_options_json(options).merge(
        pickup_address: pickup_address_with_country,
        delivery_address: delivery_address_with_country
      )
    end

    def with_address_index_json(options = {})
      as_index_json(options).merge(
        pickup_address: pickup_address_with_country,
        delivery_address: delivery_address_with_country
      )
    end

    private

    def update_carriage_properties!
      %w[on_carriage pre_carriage].each do |carriage|
        self["has_#{carriage}"] = trucking.dig(carriage, 'address_id').present?
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
      last_shipment_in_this_hour = Legacy::Shipment.with_deleted.where('imc_reference LIKE ?', first_part + '%').last
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
      Contact.joins(:shipment_contacts).where(shipment_contacts: { contact_type: type, shipment_id: id })
    end

    def desired_start_date_is_a_datetime?
      return if desired_start_date.nil?

      errors.add(:desired_start_date, 'must be a DateTime') unless desired_start_date.is_a?(ActiveSupport::TimeWithZone)
    end

    def set_default_trucking
      self.trucking ||= { on_carriage: { truck_type: '' }, pre_carriage: { truck_type: '' } }
    end

    def itinerary_trip_match
      return if trip.nil? || trip.itinerary_id == itinerary_id

      errors.add(:itinerary, "id does not match the trips's itinerary_id")
    end

    def set_distinct_id
      self.distinct_id = [Time.zone.now.gmtime.tv_sec, SecureRandom.uuid].join('-') if user_id.blank?
    end

    def set_organization
      self.organization_id ||= user&.organization_id
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
#  billing                             :integer          default("external")
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
#  distinct_id                         :uuid
#  incoterm_id                         :integer
#  itinerary_id                        :integer
#  legacy_user_id                      :integer
#  organization_id                     :uuid
#  origin_hub_id                       :integer
#  origin_nexus_id                     :integer
#  quotation_id                        :integer
#  sandbox_id                          :uuid
#  tenant_id                           :integer
#  tender_id                           :uuid
#  trip_id                             :integer
#  user_id                             :uuid
#
# Indexes
#
#  index_shipments_on_organization_id  (organization_id)
#  index_shipments_on_sandbox_id       (sandbox_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tenant_id        (tenant_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tender_id        (tender_id)
#  index_shipments_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (destination_hub_id => hubs.id) ON DELETE => nullify
#  fk_rails_...  (destination_nexus_id => nexuses.id) ON DELETE => nullify
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (origin_hub_id => hubs.id) ON DELETE => nullify
#  fk_rails_...  (origin_nexus_id => nexuses.id) ON DELETE => nullify
#  fk_rails_...  (user_id => users_users.id)
#
