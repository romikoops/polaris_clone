# frozen_string_literal: true

class Shipment < ApplicationRecord
  extend ShippingTools
  # include ActiveModel::Validations
  STATUSES = %w(
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
  ).freeze
  LOAD_TYPES = TransportCategory::LOAD_TYPES
  DIRECTIONS = %w(import export).freeze

  # Validations
  { status: STATUSES, load_type: LOAD_TYPES, direction: DIRECTIONS }.each do |attribute, array|
    CustomValidations.inclusion(self, attribute, array)
  end

  validates_with MaxAggregateDimensionsValidator
  validates_with HubNexusMatchValidator

  validate :planned_pickup_date_is_a_datetime?
  validate :desired_start_date_is_a_datetime?
  validate :user_tenant_match
  validate :itinerary_trip_match

  # validates :total_goods_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ActiveRecord Callbacks
  before_validation :assign_uuid, :generate_imc_reference,
                    :set_default_trucking, :set_tenant,
                    on: :create
  before_validation :update_carriage_properties!, :sync_nexuses, :set_default_destination_dates

  has_paper_trail

  # ActiveRecord associations
  belongs_to :user
  belongs_to :quotation, optional: true
  belongs_to :tenant
  has_many :documents
  has_many :shipment_contacts
  has_many :contacts, through: :shipment_contacts
  belongs_to :origin_nexus, class_name: 'Nexus', optional: true
  belongs_to :destination_nexus, class_name: 'Nexus', optional: true
  belongs_to :origin_hub, class_name: 'Hub', optional: true
  belongs_to :destination_hub, class_name: 'Hub', optional: true
  belongs_to :route, optional: true
  belongs_to :itinerary, optional: true
  belongs_to :trip, optional: true
  belongs_to :transport_category, optional: true
  has_many :containers
  has_many :cargo_items
  has_many :cargo_item_types, through: :cargo_items
  has_one :aggregated_cargo
  has_many :conversations
  has_many :messages, through: :conversations
  has_many :charge_breakdowns do
    def to_schedules_charges
      reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
    end
  end
  self.per_page = 4
  accepts_nested_attributes_for :containers, allow_destroy: true
  accepts_nested_attributes_for :cargo_items, allow_destroy: true
  accepts_nested_attributes_for :contacts, allow_destroy: true
  accepts_nested_attributes_for :documents, allow_destroy: true
  filterrific(
    default_filter_params: { sorted_by: 'booking_placed_at_desc' },
    available_filters: %i(
      user_name
      company_name
      reference_number
      sorted_by
      user_search
      requested
      open
      finished
      rejected
      archived
      for_tenant
    )
  )
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

  scope :user_name, lambda { |query|
    user_ids = User.where('first_name ILIKE ? OR last_name ILIKE ?', "%#{query}%", "%#{query}%").ids
    where(user_id: user_ids)
  }

  scope :company_name, lambda { |query|
    user_ids = User.where('company_name ILIKE ? ', "%#{query}%").ids
    where(user_id: user_ids)
  }

  scope :reference_number, lambda { |query|
    where('imc_reference ILIKE ? ', "%#{query}%")
  }

  scope :hub_names, lambda { |query|
    hub_ids = Hub.where('name ILIKE ?', "%#{query}%").ids
    where('origin_hub_id IN (?) OR destination_hub_id IN (?)', hub_ids, hub_ids)
  }

  scope :for_tenant, lambda { |_query|
    tenant = Tenant.find_by_subdomain
    tenant.shipments
  }

  scope :user_search, lambda { |query|
    user_name(query).or(Shipment.company_name(query)).or(Shipment.reference_number(query))
                    .or(Shipment.hub_names(query))
  }

  # STATUSES.each do |status|
  #   scope status, -> { where(status: status) }
  # end

  %i(ocean air rail).each do |mot|
    scope mot, -> { joins(:itinerary).where('itineraries.mode_of_transport = ?', mot) }
  end

  # Class methods

  # Instance methods

  def total_price
    return nil if trip_id.nil?

    price = charge_breakdowns.where(trip_id: trip_id).first.charge('grand_total').price

    { value: price.value, currency: price.currency }
  end

  def edited_total
    return nil if trip_id.nil?

    price = charge_breakdowns.where(trip_id: trip_id).first.charge('grand_total').edited_price

    return nil if price.nil?

    { value: price.value, currency: price.currency }
  end

  def origin_layover
    return nil if trip.nil?

    trip.layovers.hub_id(origin_hub_id).try(:first)
  end

  def destination_layover
    return nil if trip.nil?

    trip.layovers.hub_id(destination_hub_id).try(:first)
  end

  def origin_layover=(layover)
    set_trip_using_layover(layover)

    self.planned_etd  = layover.etd
    self.closing_date = layover.closing_date
    self.origin_hub   = layover.hub
  end

  def destination_layover=(layover)
    set_trip_using_layover(layover)

    self.planned_eta     = layover.eta
    self.destination_hub = layover.hub
  end

  def set_trip_using_layover(layover)
    raise 'Trip Mismatch' unless trip_id.nil? || layover.trip.id == trip_id

    self.trip      ||= layover.trip
    self.itinerary ||= layover.trip.itinerary
  end

  def pickup_address
   Address.where(id: trucking.dig('pre_carriage', 'address_id')).first
  end

  def delivery_address
   Address.where(id: trucking.dig('on_carriage', 'address_id')).first
  end

  def pickup_address_with_country
    pickup_address.as_json(include: :country)
  end

  def delivery_address_with_country
    delivery_address.as_json(include: :country)
  end

  def import?
    direction == 'import'
  end

  def export?
    direction == 'export'
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

  def cargo_units
    send("#{load_type}s")
  end

  def cargo_units=(value)
    send("#{load_type}s=", value)
  end

  def selected_day_attribute
    has_pre_carriage? ? :planned_pickup_date : :planned_origin_drop_off_date
  end

  def selected_day
    self[selected_day_attribute]
  end

  def selected_day=(value)
    self[selected_day_attribute] = value
  end

  def has_dangerous_goods?
    return aggregated_cargo.dangerous_goods? unless aggregated_cargo.nil?
    return cargo_units.any?(&:dangerous_goods) unless cargo_units.nil?
    nil
  end

  def has_non_stackable_cargo?
    return true unless aggregated_cargo.nil?
    return cargo_units.any? { |cargo_unit| !cargo_unit.stackable } unless cargo_units.nil?
    nil
  end

  def trucking=(value)
    super

    update_carriage_properties!
  end

  def mode_of_transport
    itinerary.try(:mode_of_transport)
  end

  def has_on_carriage=(_value)
    raise 'This property is read only. Please write to the trucking property instead.'
  end

  def has_pre_carriage=(_value)
    raise 'This property is read only. Please write to the trucking property instead.'
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

  def has_customs?
    !!selected_offer.dig('customs')
  end

  def has_insurance?
    !!selected_offer.dig('insurance')
  end

  def accept!
    update!(status: 'confirmed')
  end

  def finish!
    update!(status: 'finished')
  end

  def decline!
    update!(status: 'declined')
  end

  def ignore!
    update!(status: 'ignored')
  end

  def archive!
    update!(status: 'archived')
  end

  def etd
    planned_etd
  end

  def eta
    planned_eta
  end

  def selected_offer
    charge_breakdowns.selected.to_nested_hash
  end

  def view_offers(index)
  end
  deprecate :view_offers, deprecator: APP_DEPRECATION

  def as_options_json(options = {})
    new_options = options.reverse_merge(
      methods: %i(selected_offer mode_of_transport),
      include: [
        :destination_nexus,
        :origin_nexus,
        {
          destination_hub: {
            include: { address: { only: %i(geocoded_address latitude longitude) } }
          }
        },
        {
          origin_hub: {
            include: { address: { only: %i(geocoded_address latitude longitude) } }
          }
        }
      ]
    )
    as_json(new_options)
  end

  def as_index_json(options = {})
    new_options = options.reverse_merge(
      methods: %i(total_price mode_of_transport cargo_units selected_offer edited_total),
      include: [
        :destination_nexus,
        :origin_nexus,
        {
          destination_hub: {}
        },
        {
          origin_hub: {}
        }
      ]
    )
    as_json(new_options)
  end

  def with_address_options_json(options = {})
    as_options_json(options).merge(
      pickup_address:   pickup_address_with_country,
      delivery_address: delivery_address_with_country
    )
  end

  def with_address_index_json(options = {})
    as_index_json(options).merge(
      pickup_address:   pickup_address_with_country,
      delivery_address: delivery_address_with_country
    )
  end

  def create_charge_breakdowns_from_schedules_charges!
    schedules_charges.map do |hub_route_key, schedule_charges|
      origin_hub_id, destination_hub_id = *hub_route_key.split('-').map(&:to_i)
      next unless origin_hub_id == origin_hub_id && destination_hub_id == destination_hub_id

      charge_breakdown = ChargeBreakdown.create!(shipment: self, trip: trip)
      Charge.create_from_schedule_charges(schedule_charges, charge_breakdown)
      charge_breakdown.charge('cargo').update_price!
    end
  end

  def self.create_all_empty_charge_breakdowns!
    where.not(id: ChargeBreakdown.pluck(:shipment_id).uniq, schedules_charges: {})
         .each(&:create_charge_breakdowns_from_schedules_charges!)
  end

  def self.update_refactor_shipments
    Shipment.where.not(itinerary: nil).each do |s|
      itinerary = s.itinerary
      s.destination_nexus = itinerary.last_stop.hub.nexus
      s.origin_nexus = itinerary.first_stop.hub.nexus
      s.trucking['on_carriage']['address_id'] ||= itinerary.last_stop.hub.id if s.has_on_carriage
      s.trucking['pre_carriage']['address_id'] ||= itinerary.first_stop.hub.id if s.has_pre_carriage
      s.save!
    end
  end

  def valid_for_itinerary?(itinerary_id)
    current_itinerary = itinerary

    self.itinerary_id = itinerary_id
    return_bool = valid?

    self.itinerary = current_itinerary

    return_bool
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

  def assign_uuid
    self.uuid = SecureRandom.uuid
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
    self.tenant_id ||= user.tenant_id
  end

  def sync_nexuses
    %w(origin destination).each do |target|
      next if self["#{target}_hub"].nil?

      self["#{target}_nexus"] ||= self["#{target}_hub"]
    end
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
