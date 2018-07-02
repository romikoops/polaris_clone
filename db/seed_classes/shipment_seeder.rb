require "#{Rails.root}/db/seed_helpers/iterator_helpers.rb"

class ShipmentSeeder
  include IteratorHelpers

  def initialize(options={})
  end

  def perform
    counter = 0
    nested_each_with_times(
      User.shipper.to_a, 1,
      Shipment::STATUSES, 0..2,
      Shipment::LOAD_TYPES, 0..1,
      Shipment::DIRECTIONS, 0..1
    ) do |user, status, load_type, direction|
      nested_each_with_times(
        Trip.where(itinerary: user.tenant.itineraries).to_a, 0.01
      ) do |trip|

        counter += 1
        puts "------"
        p [user.email, status, load_type, direction, trip]
        puts counter
        puts "------"
        # @shipemnt = Shipment.new(
        #   user: user,
        #   status: status
        #   load_type: load_type,
        #   direction: direction,
        # )
        # origin_layover, destination_layover = *trip.layovers.sample(2)
        # @shipment.origin_layover      = origin_layover
        # @shipment.destination_layover = destination_layover
        # 
        # @shipment.planned_origin_drop_off_date = random_origin_drop_off_date
        # @shipment.booking_placed_at = random_booking_placed_at
      end
    end

    counter
  end

  def random_origin_drop_off_date(origin_layover)
    @shipment.origin_layover.closing_date - rand(2..30).hours
  end

  def random_booking_placed_at(planned_origin_drop_off_date)
    @shipment.planned_origin_drop_off_date - rand(1..8).days - rand(2..30).hours
  end
end

# Shipment Columns
# 
#  To Be Removed
#    - pre_carriage_distance_km: decimal
#    - on_carriage_distance_km: decimal 
#    - haulage: string 
#    - schedules_charges: jsonb 
#    - schedule_set: jsonb
#    - route_id: integer
#    - hs_code: string
#    - total_price: jsonb
#  
#  Current
#    - id: integer
#    - user_id: integer
#       - tenant_id: integer 
#    - status: string
#    - load_type: string
#    - direction: string
#  (
#    - planned_pickup_date: datetime
#    - planned_origin_drop_off_date: datetime
#    - trucking: jsonb 
#       - has_pre_carriage: boolean
#       - has_on_carriage: boolean

#    - origin_hub_id: integer 
#    - destination_hub_id: integer 
#       - origin_nexus_id: integer 
#       - destination_nexus_id: integer 
#    - planned_eta: datetime 
#    - planned_etd: datetime 
#    - closing_date: datetime 
#  )
#       - trip_id: integer 
#           - itinerary_id: integer 
#    - customs_credit: boolean
#    - total_goods_value: jsonb 
#    - eori: string
#    - booking_placed_at: datetime 
#    - cargo_notes: string 
#    - notes: string 
#    - insurance: jsonb 
#    - customs: jsonb 
#    - transport_category_id: integer 
#    - incoterm_id: integer 
#    - incoterm_text: string 
# 
#    - uuid: string
#    - imc_reference: string
#    - created_at: datetime 
#    - updated_at: datetime
# 
# Shipment Has Many/One Relations
#    - documents
#    - shipment_contacts
#    - contacts, through: :shipment_contacts
#    - containers
#    - cargo_items
#    - cargo_item_types, through: :cargo_items
#    - conversations
#    - messages, through: :conversation
#    - charge_breakdowns
#    - aggregated_cargo


