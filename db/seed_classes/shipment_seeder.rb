# frozen_string_literal: true

require "#{Rails.root}/db/seed_helpers/iterator_helpers.rb"

class ShipmentSeeder
  include IteratorHelpers

  def initialize(options = {})
    @users = determine_users_from_options(options)
  end

  def perform
    print 'Seeding Shipments'

    counter = 0
    nested_each_with_times(
      @users.to_a, 1,
      %w(requested confirmed finished), 1,
      Shipment::LOAD_TYPES, 1,
      Shipment::DIRECTIONS, 1
    ) do |user, status, load_type, direction|
      puts  "\n\n  #{user.tenant.name.blue}" + " | #{user.full_name} | #{status} | " \
            "#{load_type} | #{direction}".light_blue

      print '      New Shipment ids:  '

      nested_each_with_times(
        Trip.where(itinerary_id: user.tenant.itineraries.ids.sample(10)).to_a.sample(15), 0.6
      ) do |trip|
        @cargo_class = TransportCategory::LOAD_TYPE_CARGO_CLASSES[load_type].sample

        next unless pricing_exists?(trip)

        counter += 1

        @shipment = Shipment.new(
          user: user,
          status: status,
          load_type: load_type,
          direction: direction,
          total_goods_value: rand(1000..2500)
        )

        origin_layover, destination_layover = *trip.layovers.sample(2).sort_by do |layover|
          layover.stop.index
        end

        @shipment.origin_layover      = origin_layover
        @shipment.destination_layover = destination_layover

        @shipment.planned_origin_drop_off_date = random_origin_drop_off_date
        @shipment.booking_placed_at            = random_booking_placed_at
        @shipment.planned_destination_collection_date = random_origin_drop_off_date
        @shipment.cargo_units = random_cargo_units

        @shipment.save

        OfferCalculatorService::ChargeCalculator.new(
          shipment: @shipment,
          trucking_data: {},
          schedule: schedule,
          user: user
        ).perform

        create_shipment_contacts(user)

        @shipment.id && print(@shipment.id, '  ')
      end
    end
    puts
    counter
  end

  private

  def schedule
    Schedule.new(
      origin_hub_id: @shipment.origin_hub.id,
      destination_hub_id: @shipment.destination_hub.id,
      origin_hub_name: @shipment.origin_hub.name,
      destination_hub_name: @shipment.destination_hub.name,
      mode_of_transport: @shipment.mode_of_transport,
      eta: @shipment.planned_eta,
      etd: @shipment.planned_etd,
      closing_date: @shipment.closing_date,
      trip_id: @shipment.trip_id
    )
  end

  def random_cargo_units
    @shipment.load_type == 'cargo_item' ? random_cargo_items : random_containers
  end

  def random_cargo_items
    CargoItem.extract((1..rand(1..5)).map { random_cargo_item_attributes })
  end

  def random_containers
    Container.extract((1..rand(1..5)).map { random_container_attributes })
  end

  def random_cargo_item_attributes
    {
      payload_in_kg: rand(50..200),
      dimension_x: rand(50..120),
      dimension_y: rand(50..80),
      dimension_z: rand(50..158),
      quantity: rand(1..5),
      cargo_item_type: @shipment.user.tenant.cargo_item_types.sample,
      dangerous_goods: false,
      stackable: true
    }
  end

  def random_container_attributes
    {
      payload_in_kg: rand(100..300),
      size_class: @cargo_class,
      tare_weight: Container::TARE_WEIGHTS[@cargo_class.to_sym],
      quantity: rand(1..5),
      dangerous_goods: false
    }
  end

  def random_origin_drop_off_date
    @shipment.origin_layover.closing_date - rand(90..200).hours
  end

  def random_booking_placed_at
    @shipment.planned_origin_drop_off_date - rand(400..1500).hours
  end

  def random_destination_collection_date
    @shipment.destination_layover.eta + rand(5..500).hours
  end

  def create_shipment_contacts(user)
    available_contacts = user.contacts.to_a.clone

    ShipmentContact::CONTACT_TYPES.each do |contact_type|
      ShipmentContact.create(
        shipment: @shipment,
        contact: available_contacts.delete(available_contacts.sample),
        contact_type: contact_type
      )
    end
  end

  def determine_users_from_options(options)
    if options[:user_filter]
      User.where(options[:user_filter])
    elsif options[:tenant_filter]
      User.where(tenant: Tenant.where(options[:tenant_filter])).shipper
    else
      User.shipper
    end
  end

  def pricing_exists?(trip)
    !!Pricing.where(
      itinerary: trip.itinerary,
      transport_category: trip.tenant_vehicle.vehicle.transport_categories.cargo_class(@cargo_class)
    ).first
  end
end

# NOTES

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
