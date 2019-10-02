# frozen_string_literal: true

module Pricings
  class Pricing < ApplicationRecord
    attr_accessor :transient_marked_as_old
    self.ignored_columns = ['disabled']

    include ::Pricings::Legacy
    has_paper_trail
    belongs_to :itinerary, class_name: 'Legacy::Itinerary'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'
    belongs_to :user, optional: true
    has_many :fees, class_name: 'Pricings::Fee', dependent: :destroy
    has_many :pricing_requests, dependent: :destroy
    has_many :margins, class_name: 'Pricings::Margin'
    has_many :notes, dependent: :destroy, as: :target
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    validates :itinerary_id, uniqueness: {
      scope: %i(tenant_id user_id tenant_vehicle_id effective_date expiration_date cargo_class load_type legacy_id)
    }

    scope :for_mode_of_transport, ->(mot) { joins(:itinerary).where(itineraries: { mode_of_transport: mot.downcase }) }
    scope :for_load_type, (lambda do |load_type|
      where(load_type: load_type.downcase)
    end)
    scope :for_cargo_classes, (lambda do |cargo_classes|
      where(cargo_class: cargo_classes.map(&:downcase))
    end)
    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new(
                "(#{arel_table[:effective_date].name}, #{arel_table[:expiration_date].name})"
              ),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)

    def as_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(data carrier service_level),
        only: %i(
          effective_date expiration_date wm_rate itinerary_id load_type cargo_class
          tenant_id id tenant_vehicle_id internal
        )
      )
      super(new_options)
    end

    def for_table_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(data load_type cargo_class carrier service_level itinerary_name mode_of_transport),
        only: %i(
          effective_date expiration_date wm_rate itinerary_id
          tenant_id id tenant_vehicle_id internal
        )
      )
      as_json(new_options)
    end

    def itinerary_name
      itinerary&.name
    end

    def mode_of_transport
      itinerary&.mode_of_transport
    end

    def data
      fees.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
    end

    def carrier
      tenant_vehicle&.carrier&.name
    end

    def service_level
      tenant_vehicle&.name
    end
  end
end

# == Schema Information
#
# Table name: pricings_pricings
#
#  id                :uuid             not null, primary key
#  wm_rate           :decimal(, )
#  effective_date    :datetime
#  expiration_date   :datetime
#  tenant_id         :bigint
#  cargo_class       :string
#  load_type         :string
#  user_id           :bigint
#  itinerary_id      :bigint
#  tenant_vehicle_id :integer
#  legacy_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  internal          :boolean          default(FALSE)
#  group_id          :uuid
#
