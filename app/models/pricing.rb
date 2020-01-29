# frozen_string_literal: true

class Pricing < Legacy::Pricing
  attr_accessor :transient_marked_as_old

  has_paper_trail
  belongs_to :itinerary
  belongs_to :tenant
  belongs_to :transport_category
  belongs_to :tenant_vehicle
  belongs_to :user, optional: true
  has_many :pricing_details, as: :priceable, dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy
  has_many :pricing_requests, dependent: :destroy
  has_many :notes, dependent: :destroy, as: :target
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

  self.per_page = 12
end

# == Schema Information
#
# Table name: pricings
#
#  id                    :bigint           not null, primary key
#  effective_date        :datetime
#  expiration_date       :datetime
#  internal              :boolean          default(FALSE)
#  uuid                  :uuid
#  wm_rate               :decimal(, )
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  itinerary_id          :bigint
#  sandbox_id            :uuid
#  tenant_id             :bigint
#  tenant_vehicle_id     :integer
#  transport_category_id :bigint
#  user_id               :bigint
#
# Indexes
#
#  index_pricings_on_itinerary_id           (itinerary_id)
#  index_pricings_on_sandbox_id             (sandbox_id)
#  index_pricings_on_tenant_id              (tenant_id)
#  index_pricings_on_transport_category_id  (transport_category_id)
#  index_pricings_on_user_id                (user_id)
#  index_pricings_on_uuid                   (uuid) UNIQUE
#
