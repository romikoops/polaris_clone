class Shipment < ApplicationRecord
  extend ShippingTools
  include ActiveModel::Validations
  STATUSES = %w( 
    booking_process_started
    requested_by_unconfirmed_account
    requested
    pending
    confirmed
    declined
    ignored
    finished
  )
  LOAD_TYPES = TransportCategory::LOAD_TYPES
  DIRECTIONS = %w(import export)

  # Validations
  { status: STATUSES, load_type: LOAD_TYPES, direction: DIRECTIONS }.each do |attribute, array|
    CustomValidations.inclusion(self, attribute, array)
  end

  # validates_with MaxAggregateDimensionsValidator

  validate :planned_pickup_date_is_a_datetime?
  validates :pre_carriage_distance_km, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :on_carriage_distance_km,  numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  # validates :total_goods_value,        numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ActiveRecord Callbacks
  before_create :assign_uuid
  before_create :generate_imc_reference
  before_create :set_default_trucking

  # Basic associations
  belongs_to :user, optional: true
  belongs_to :consignee, optional: true
  belongs_to :tenant, optional: true
  has_many :documents
  has_many :shipment_contacts
  has_many :contacts, through: :shipment_contacts
  belongs_to :origin, class_name: "Location", optional: true
  belongs_to :destination, class_name: "Location", optional: true
  belongs_to :origin_hub, class_name: "Hub", optional: true
  belongs_to :destination_hub, class_name: "Hub", optional: true
  belongs_to :route, optional: true
  belongs_to :itinerary, optional: true
  belongs_to :transport_category, optional: true
  has_many :containers
  has_many :cargo_items
  has_many :cargo_item_types, through: :cargo_items
  has_one :aggregated_cargo
  belongs_to :origin_hub, class_name: "Hub", optional: true
  belongs_to :destination_hub, class_name: "Hub", optional: true
  has_many :conversations

  accepts_nested_attributes_for :containers, allow_destroy: true
  accepts_nested_attributes_for :cargo_items, allow_destroy: true
  accepts_nested_attributes_for :contacts, allow_destroy: true
  accepts_nested_attributes_for :documents, allow_destroy: true

  # Scopes
  scope :has_pre_carriage, -> { where(has_pre_carriage: true) }
  scope :has_on_carriage,  -> { where(has_on_carriage:  true) }
  STATUSES.each do |status|
    scope status, -> { where(status: status) }
  end

  [:ocean, :air, :rail].each do |mot|
    scope mot, -> { joins(:itinerary).where("itineraries.mode_of_transport = ?", mot) }
  end

  # Class methods
  def self.determine_haulage_from_ids(item_ids)
    pricings = []
    item_ids.each do |item_id|
      s = item_id.split("-")
      id = s[0]
      pricing_type = s[1]

      case pricing_type
      when "truck"
        pricing = TruckingPricing.find_by_id(id)
        pricings << pricing
      when "train"
        pricing = TrainPricing.find_by_id(id)
        pricings << pricing
      when "ocean"
        pricing = OceanPricing.find_by_id(id)
        pricings << pricing
      else
        raise "Something went wrong."
      end
    end

    pricings
  end

  # Instance methods

  def import?
    direction == "import"
  end

  def export?
    direction == "export"
  end

  def shipper
    find_contacts("shipper").first
  end

  def consignee
    find_contacts("consignee").first
  end

  def notifyees
    find_contacts("notifyee")
  end

  def cargo_units
    send("#{load_type}s")
  end

  def has_dangerous_goods?
    _aggregated_cargo = self.aggregated_cargo
    _cargo_units      = cargo_units
    return _aggregated_cargo.dangerous_goods? unless _aggregated_cargo.nil?
    return _cargo_units.any? { |cargo_unit| cargo_unit.dangerous_goods } unless _cargo_units.nil?
    nil  
  end

  def has_non_stackable_cargo?
    _aggregated_cargo = self.aggregated_cargo
    _cargo_units      = cargo_units
    return true unless _aggregated_cargo.nil?
    return _cargo_units.any? { |cargo_unit| !cargo_unit.stackable } unless _cargo_units.nil?
    nil
  end

  def mode_of_transport
    itinerary.mode_of_transport
  end

  def has_customs?
    !!customs
  end

  def has_insurance?
    !!insurance
  end

  def full_haulage_to_string
    self.origin.geocoded_address + " \u2192 " + self.route.stops_as_string + " \u2192 " + self.destination.geocoded_address
  end

  def individualized_haulage_to_string
    stop_addresses = []
    get_all_pricings_in_haulage.each do |pricing|
      unless pricing.class.name == "TruckingPricing"
        stop_addresses << pricing.starthub_name
        stop_addresses << pricing.endhub_name
      end
    end

    self.origin.geocoded_address + " \u2192 " + stop_addresses.uniq.join(" \u2192 ") + " \u2192 " + self.destination.geocoded_address
  end

  def determine_full_haulage_pricings(starthub, endhub)
    route = determine_route!(starthub, endhub)
    route.get_all_pricings
  end

  def determine_route!(origin, destination)
    route = Route.get_route(origin, destination)
    self.update_attribute(:route, route)
    route
  end

  def set_haulage_from_haulage_pricings(haulage_pricings)
    item_ids = []
    haulage_pricings.each do |pricing|
      case pricing.class.name
      when "TruckingPricing"
        item_id = pricing.id.to_s + "-" + "truck"
      when "TrainPricing"
        item_id = pricing.id.to_s + "-" + "train"
      when "OceanPricing"
        item_id = pricing.id.to_s + "-" + "ocean"
      else
        raise "Something went wrong."
      end
      item_ids << item_id
    end
    set_haulage_from_ids(item_ids)
  end

  def set_haulage_from_ids(item_ids)
    self.update_attribute(:haulage, item_ids.join(";"))
  end

  def get_all_pricings_in_haulage
    item_ids = self.haulage.split(";")
    pricings = []
    item_ids.each do |item_id|
      s = item_id.split("-")
      id = s[0]
      pricing_type = s[1]

      case pricing_type
      when "truck"
        pricing = TruckingPricing.find_by_id(id)
      when "train"
        pricing = TrainPricing.find_by_id(id)
      when "ocean"
        pricing = OceanPricing.find_by_id(id)
      else
        raise "Something went wrong."
      end

      pricings << pricing
    end

    pricings
  end

  def total_price_of_haulage(pricings)
    total_price = 0
    pricings.each_with_index do |pricing, index|
      case pricing.class.name
      when "TruckingPricing"
        if index == 0 # Pre-Carriage
          total_price += pricing.price(self.origin.geocoded_address, self.route.stops.first.geocoded_address)
        else # On-Carriage
          total_price += pricing.price(self.route.stops.last.geocoded_address, self.destination.geocoded_address)
        end
      when "OceanPricing"
        total_price += pricing.price
      when "TrainPricing"
        total_price += pricing.price
      else
        raise "Something went wrong"
      end
    end
    
    total_price
  end

  def booked?
    self.status == "booked"    
  end

  def confirm!
    self.update_attributes(status: "confirmed")
    self.save!
  end

  def finished!
    self.update_attributes(status: "finished")
    self.save!
  end

  def decline!
    self.update_attributes(status: "declined")
    self.save!
  end

  def ignore!
    self.update_attributes(status: "ignored")
    self.save!
  end

  def is_lcl?
    raise "Not implemented"
  end

  def etd
    planned_etd
  end

  def eta
    planned_eta
  end

  def has_on_carriage?
    has_on_carriage
  end

  def has_pre_carriage?
    has_pre_carriage
  end

  def cargo_charges
    schedule_set.reduce({}) do |cargo_charges, schedule|
      cargo_charges.merge schedules_charges[schedule["hub_route_key"]]["cargo"]
    end
  end

  def eta_catchup
    ships = Shipment.all
    ships.each do |s|
      scheds = []
      s.schedule_set.each do |ss|
        scheds.push(Schedule.find(ss['id']))
      end
      if scheds.first && scheds.first.etd && scheds.last && scheds.last.eta
        s.planned_etd = scheds.first.etd
        s.planned_eta = scheds.last.eta
        s.save!
      end
    end
  end

  def self.test_email
    user = User.find_by_email("demo@demo.com")
    shipment = user.shipments.find_by(status: "requested")
    ShipmentMailer.tenant_notification(user, shipment).deliver_now
    ShipmentMailer.shipper_notification(user, shipment).deliver_now
    shipper_confirmation_email(user, shipment)
  end

  def self.update_hubs_on_shipments
    Shipment.all.each do |s|
      if s.origin_id != nil && s.destination_id != nil && s.origin && s.destination
        if s.schedule_set && s.schedule_set[0] && s.schedule_set[0]["hub_route_key"] && 
          hub_keys = s.schedule_set[0]["hub_route_key"].split("-")
          if s.origin.location_type
            s.origin_hub_id = s.origin.id
          else
            s.origin_hub_id = hub_keys[0].to_i
            s.destination_hub_id = hub_keys[1].to_i
          end
          if s.destination.location_type
            s.destination_hub_id = s.destination.id
          else
            
            s.destination_hub_id = hub_keys[1].to_i
          end
          s.save!
        end
      end
    end
  end

  private

  def generate_imc_reference
    now = DateTime.now
    day_of_the_year = now.strftime("%d%m")
    hour_as_letter = ("A".."Z").to_a[now.hour - 1]
    year = now.year.to_s[-2..-1]
    first_part = day_of_the_year + hour_as_letter + year
    last_shipment_in_this_hour = Shipment.where("imc_reference LIKE ?", first_part + "%").last
    if last_shipment_in_this_hour
      last_serial_number = last_shipment_in_this_hour.imc_reference[first_part.length .. -1].to_i
      new_serial_number = last_serial_number + 1
      serial_code = new_serial_number.to_s.rjust(5, "0")
    else
      serial_code = "1".rjust(5, "0")
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
      WHERE shipments.id = #{self.id}
      AND   shipment_contacts.contact_type = '#{type}'
    ")    
  end

  def planned_pickup_date_is_a_datetime?
    return if planned_pickup_date.nil?
    errors.add(:planned_pickup_date, 'must be a DateTime') unless planned_pickup_date.is_a?(ActiveSupport::TimeWithZone) 
  end

  def set_default_trucking
    no_trucking_h = { truck_type: '' }
    self.trucking ||= { on_carriage: no_trucking_h, pre_carriage: no_trucking_h }
  end
end
