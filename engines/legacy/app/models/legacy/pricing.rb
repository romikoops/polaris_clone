# frozen_string_literal: true

module Legacy
  class Pricing < ApplicationRecord
    self.table_name = 'pricings'

    attr_accessor :transient_marked_as_old

    has_paper_trail
    belongs_to :itinerary
    belongs_to :tenant
    belongs_to :transport_category, class_name: 'Legacy::TransportCategory'
    belongs_to :tenant_vehicle
    belongs_to :user, optional: true
    has_many :pricing_details, as: :priceable, dependent: :destroy
    has_many :pricing_requests, dependent: :destroy
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    before_validation -> { self.uuid ||= SecureRandom.uuid }, on: :create

    validates :transport_category, uniqueness: {
      scope: %i(itinerary_id tenant_id user_id tenant_vehicle_id effective_date expiration_date)
    }

    delegate :load_type, to: :transport_category
    delegate :cargo_class, to: :transport_category
    scope :for_mode_of_transport, ->(mot) { joins(:itinerary).where(itineraries: { mode_of_transport: mot.downcase }) }
    scope :for_load_type, (lambda do |load_type|
      joins(:transport_category).where(transport_categories: { load_type: load_type.downcase })
    end)
    scope :for_cargo_classes, (lambda do |cargo_classes|
      joins(:transport_category).where(transport_categories: { cargo_class: cargo_classes.map(&:downcase) })
    end)
    scope :for_dates, (lambda do |start_date, end_date|
      where(Arel::Nodes::InfixOperation.new(
              'OVERLAPS',
              Arel::Nodes::SqlLiteral.new("(#{arel_table[:effective_date].name}, #{arel_table[:expiration_date].name})"),
              Arel::Nodes::SqlLiteral.new("(DATE '#{start_date}', DATE '#{end_date}')")
            ))
    end)

    def as_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(data load_type cargo_class carrier service_level),
        only: %i(
          effective_date expiration_date wm_rate itinerary_id internal
          tenant_id transport_category_id id currency_name tenant_vehicle_id user_id
        )
      )
      super(new_options)
    end

    def for_table_json(options = {})
      new_options = options.reverse_merge(
        methods: %i(data load_type cargo_class carrier service_level user_email),
        only: %i(
          effective_date expiration_date wm_rate itinerary_id internal
          tenant_id transport_category_id id currency_name tenant_vehicle_id user_id
        )
      )
      as_json(new_options)
    end

    def data
      pricing_details.map(&:to_fee_hash).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
    end

    def user_email
      user&.email
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
# Table name: pricings
#
#  id                    :bigint           not null, primary key
#  wm_rate               :decimal(, )
#  effective_date        :datetime
#  expiration_date       :datetime
#  tenant_id             :bigint
#  transport_category_id :bigint
#  user_id               :bigint
#  itinerary_id          :bigint
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  tenant_vehicle_id     :integer
#  uuid                  :uuid
#  sandbox_id            :uuid
#  internal              :boolean          default(FALSE)
#
