class Shipment < ActiveRecord::Base
  # ActiveRecord Callbacks
  before_create :assign_uuid
  before_create :generate_imc_reference

  # Basic associations
  belongs_to :shipper, class_name: "User"

  belongs_to :consignee
	has_many :documents
  has_many :shipments_notifyees
  has_many :notifyees, through: :shipments_notifyees

  belongs_to :origin, class_name: "Location"
  belongs_to :destination, class_name: "Location"

  belongs_to :route

  has_many :containers
  has_many :lcl_cargos
  
  accepts_nested_attributes_for :containers, allow_destroy: true
  accepts_nested_attributes_for :lcl_cargos, allow_destroy: true
  accepts_nested_attributes_for :notifyees, allow_destroy: true
	accepts_nested_attributes_for :documents, allow_destroy: true

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

  def accept!
    self.update_attributes(status: "accepted")
  end

  def decline!
    self.update_attributes(status: "declined")
  end

  def is_lcl?
    !self.lcl_cargos.empty?
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
end