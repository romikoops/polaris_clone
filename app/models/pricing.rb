class Pricing < ApplicationRecord
  belongs_to :itinerary
  belongs_to :tenant
  belongs_to :transport_category
  belongs_to :user, optional: true
  has_many :pricing_details, as: :priceable, dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy

  delegate :load_type, to: :transport_category

  def as_json(options={})
    new_options = options.reverse_merge(
{ methods: [:data, :exceptions, :load_type], only: [:effective_date, :expiration_date, :wm_rate, :itinerary_id, :tenant_id, :transport_category_id] }
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

