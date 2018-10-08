# frozen_string_literal: true

class Pricing < ApplicationRecord
  belongs_to :itinerary
  belongs_to :tenant
  belongs_to :transport_category
  belongs_to :tenant_vehicle
  belongs_to :user, optional: true
  has_many :pricing_details, as: :priceable, dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy

  delegate :load_type, to: :transport_category
  delegate :cargo_class, to: :transport_category
  scope :for_load_type, ->(load_type) { joins(:transport_category).where('transport_categories.load_type': load_type) }

  self.per_page = 12

  def as_json(options={})
    new_options = options.reverse_merge(
      methods: %i(data exceptions load_type cargo_class),
      only:    %i(
        effective_date expiration_date wm_rate itinerary_id
        tenant_id transport_category_id id currency_name tenant_vehicle_id user_id
      )
    )
    super(new_options)
  end

  def data
    pricing_details.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
  end

  def exceptions
    pricing_exceptions.map(&:as_json)
  end
end
