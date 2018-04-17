class PricingException < ApplicationRecord
  belongs_to :tenant
  belongs_to :pricing
  has_many :pricing_details, as: :priceable, dependent: :destroy

  def as_json(options={})

    new_options = options.reverse_merge(
      { methods: [:data], only: [:effective_date, :expiration_date] }
    )
    super(new_options)
  end

  def data
    pricing_details.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }
  end
end

