# frozen_string_literal: true

class Shipment < Legacy::Shipment
  validate :desired_start_date_is_a_datetime?
  # validate :itinerary_trip_match

  # validates :total_goods_value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # ActiveRecord Callbacks
  before_validation -> { self.uuid ||= SecureRandom.uuid }, on: :create

  belongs_to :quotation, optional: true
  belongs_to :route, optional: true

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
    new_status = confirmed_user? ? 'requested' : 'requested_by_unconfirmed_account'
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

  def route_notes
    return [] unless itinerary

    Note.where(target: itinerary&.pricings)
  end

  def confirmed_user?
    user&.activation_state == 'active'
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
