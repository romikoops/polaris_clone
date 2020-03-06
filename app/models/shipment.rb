# frozen_string_literal: true

class Shipment < Legacy::Shipment
  include PgSearch::Model

  validate :desired_start_date_is_a_datetime?
  validate :user_tenant_match
  validate :itinerary_trip_match

  # validates :total_goods_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ActiveRecord Callbacks
  before_validation -> { self.uuid ||= SecureRandom.uuid }, on: :create

  belongs_to :quotation, optional: true
  belongs_to :route, optional: true
  belongs_to :tenant

  belongs_to :origin_nexus, class_name: 'Nexus', optional: true
  belongs_to :destination_nexus, class_name: 'Nexus', optional: true
  belongs_to :origin_hub, class_name: 'Hub', optional: true
  belongs_to :destination_hub, class_name: 'Hub', optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  has_many :contacts, through: :shipment_contacts
  has_many :messages, through: :conversations
  has_many :shipment_contacts
  has_many :charge_breakdowns do

    def to_schedules_charges
      reduce({}) { |obj, charge_breakdown| obj.merge(charge_breakdown.to_schedule_charges) }
    end
  end

  has_paper_trail unless: proc { |t| t.sandbox_id.present? }

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
    where(user_id: Tenants::User.where(id: user_ids).pluck(:legacy_id))
  }

  scope :company_name, lambda { |query|
    user_ids = Profiles::Profile.where('company_name ILIKE ? ', "%#{query}%").pluck(:user_id)
    where(user_id: Tenants::User.where(id: user_ids).pluck(:legacy_id))
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
    scope mot, -> { joins(:itinerary).where(Itinerary.arel_table[:mode_of_transport].eq(mot)) }
  end

  scope :modes_of_transport, lambda { |*mots|
    mots[1..-1].reduce(send(mots.first)) do |result, mot|
      result.or(send(mot))
    end
  }

  # Class methods

  # Instance methods

  def edited_total
    return if trip_id.nil?

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

  def set_trucking_chargeable_weight(target, weight)
    trucking[target]['chargeable_weight'] = weight
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

  def cargo_count
    if aggregated_cargo
      1
    else
      cargo_units.reduce(0) { |sum, unit| sum + unit.quantity }
    end
  end

  def cargo_classes
    if aggregated_cargo
      ['lcl']
    else
      cargo_units.pluck(:cargo_class).uniq
    end
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

  def has_on_carriage=(_value)
    raise 'This property is read only. Please write to the trucking property instead.'
  end

  def has_pre_carriage=(_value)
    raise 'This property is read only. Please write to the trucking property instead.'
  end

  def has_customs?
    !!selected_offer.dig('customs')
  end

  def has_insurance?
    !!selected_offer.dig('insurance')
  end

  def confirm!
    update!(status: 'confirmed')
  end

  def finish!
    update!(status: 'finished')
  end

  def request!
    new_status = user.confirmed? ? 'requested' : 'requested_by_unconfirmed_account'
    update!(status: new_status)
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

  def view_offers(index)
  end
  deprecate :view_offers, deprecator: ActiveSupport::Deprecation.new('', Rails.application.railtie_name)

  def client_name
    shipment_user_profile.full_name
  end

  def company_name
    shipment_user_profile.company_name
  end

  def shipment_user_profile
    tenants_user = Tenants::User.with_deleted.find_by(legacy_id: user_id)
    profile = Profiles::Profile.find_by(user_id: tenants_user.id)
    Profiles::ProfileDecorator.new(profile)
  end

  def as_options_json(options = {})
    hidden_args = Pdf::HiddenValueService.new(user: user).hide_total_args
    new_options = options.reverse_merge(
      methods: %i(mode_of_transport cargo_count company_name client_name),
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
    as_json(new_options).merge(selected_offer: selected_offer(hidden_args))
  end

  def route_notes
    return [] unless itinerary

    Note.where(target: itinerary&.pricings)
  end

  def as_index_json(options = {})
    hidden_args = Pdf::HiddenValueService.new(user: user).hide_total_args
    new_options = options.reverse_merge(
      methods: %i[mode_of_transport cargo_units cargo_count edited_total company_name client_name],
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
    as_json(new_options).merge(total_price: total_price(hidden_total: hidden_args[:hidden_grand_total]))
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
#  transport_category_id               :bigint
#  trip_id                             :integer
#  user_id                             :integer
#
# Indexes
#
#  index_shipments_on_sandbox_id             (sandbox_id)
#  index_shipments_on_tenant_id              (tenant_id)
#  index_shipments_on_tender_id              (tender_id)
#  index_shipments_on_transport_category_id  (transport_category_id)
#
# Foreign Keys
#
#  fk_rails_...  (transport_category_id => transport_categories.id)
#
