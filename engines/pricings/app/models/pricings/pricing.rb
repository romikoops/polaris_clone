# frozen_string_literal: true

module Pricings
  class Pricing < ApplicationRecord
    include Legacy::Upsertable
    WM_RATIO_LOOKUP = { ocean: 1000,
                        air: 167,
                        rail: 500,
                        truck: 333 }.freeze
    attr_accessor :transient_marked_as_old

    self.ignored_columns = ["disabled"]

    UUID_V5_NAMESPACE = "0411d7c3-b309-4964-9bed-1ef2e470a1df"
    UUID_KEYS = %i[
      itinerary_id
      tenant_vehicle_id
      cargo_class
      group_id
      organization_id
    ].freeze
    has_paper_trail

    belongs_to :itinerary, class_name: "Legacy::Itinerary"
    belongs_to :organization, class_name: "Organizations::Organization"

    belongs_to :tenant_vehicle, class_name: "Legacy::TenantVehicle"
    belongs_to :user, class_name: "Users::Client", optional: true
    has_many :fees, class_name: "Pricings::Fee", dependent: :destroy
    has_many :margins, class_name: "Pricings::Margin"
    belongs_to :group, class_name: "Groups::Group", optional: true
    has_many :notes, class_name: "Legacy::Note", foreign_key: "pricings_pricing_id", dependent: :destroy
    accepts_nested_attributes_for :fees
    accepts_nested_attributes_for :notes

    validates :itinerary_id, uniqueness: {
      scope: %i[ organization_id
        user_id
        tenant_vehicle_id
        effective_date
        expiration_date
        cargo_class
        load_type
        legacy_id
        group_id
        transshipment ]
    }

    before_validation :set_validity, :generate_upsert_id

    acts_as_paranoid

    scope :current, -> { where("validity @> CURRENT_DATE") }
    scope :ordered_by, ->(col, desc = false) { order(col => desc.to_s == "true" ? :desc : :asc) }
    scope :for_mode_of_transport, ->(mot) { joins(:itinerary).where(itineraries: { mode_of_transport: mot.downcase }) }
    scope :for_load_type, (lambda do |load_type|
      where(load_type: load_type.downcase)
    end)
    scope :for_cargo_classes, (lambda do |cargo_classes|
      where(cargo_class: cargo_classes.map(&:downcase))
    end)
    scope :for_dates, (lambda do |start_date, end_date|
      where("validity && daterange(?::date, ?::date)", start_date, end_date)
    end)

    def as_json(options = {})
      new_options = options.reverse_merge(
        methods: %i[data carrier service_level],
        only: %i[
          effective_date expiration_date wm_rate vm_rate itinerary_id load_type cargo_class
          organization_id id tenant_vehicle_id internal group_id transshipment
        ]
      )
      super(new_options)
    end

    def for_table_json(options = {})
      new_options = options.reverse_merge(
        methods: %i[data load_type cargo_class carrier service_level itinerary_name mode_of_transport],
        only: %i[
          effective_date expiration_date wm_rate vm_rate itinerary_id
          organization_id id tenant_vehicle_id internal group_id
        ]
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
      fees.map(&:to_fee_hash).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
    end

    def carrier
      tenant_vehicle&.carrier&.name
    end

    def service_level
      tenant_vehicle&.name
    end

    def set_validity
      self.validity = Range.new(effective_date.to_date, expiration_date.to_date + 1.day, exclude_end: true)
    end

    def generate_upsert_id
      self.upsert_id = upsertable_id
    end
  end
end

# == Schema Information
#
# Table name: pricings_pricings
#
#  id                :uuid             not null, primary key
#  cargo_class       :string
#  deleted_at        :datetime
#  effective_date    :datetime
#  expiration_date   :datetime
#  internal          :boolean          default(FALSE)
#  load_type         :string
#  transshipment     :string
#  validity          :daterange
#  vm_rate           :decimal(, )
#  wm_rate           :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :uuid
#  itinerary_id      :bigint
#  legacy_id         :integer
#  legacy_user_id    :bigint
#  organization_id   :uuid
#  sandbox_id        :uuid
#  tenant_id         :bigint
#  tenant_vehicle_id :integer
#  upsert_id         :uuid
#  user_id           :uuid
#
# Indexes
#
#  index_pricings_pricings_on_cargo_class        (cargo_class)
#  index_pricings_pricings_on_deleted_at         (deleted_at)
#  index_pricings_pricings_on_group_id           (group_id)
#  index_pricings_pricings_on_itinerary_id       (itinerary_id)
#  index_pricings_pricings_on_legacy_user_id     (legacy_user_id)
#  index_pricings_pricings_on_load_type          (load_type)
#  index_pricings_pricings_on_organization_id    (organization_id)
#  index_pricings_pricings_on_sandbox_id         (sandbox_id)
#  index_pricings_pricings_on_tenant_id          (tenant_id)
#  index_pricings_pricings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_pricings_pricings_on_upsert_id          (upsert_id)
#  index_pricings_pricings_on_user_id            (user_id)
#  index_pricings_pricings_on_validity           (validity) USING gist
#  pricing_upsert                                (upsert_id,validity) WHERE (deleted_at IS NULL) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
