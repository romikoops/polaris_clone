class PricingDetail < ApplicationRecord
  belongs_to :tenant
  belongs_to :priceable, polymorphic: true

  def as_json(options={})

    new_options = options.reverse_merge(
      { methods: shipping_type, only: [] }
    )
    super(new_options)
  end

  def BAS
    {
      rate: rate,
      rate_basis: rate_basis,
      currency: currency_id,
      hw_threshold: hw_threshold,
      hw_rate_basis: hw_rate_basis,
      min: min,
      range: range
    }.compact.with_indifferent_access
  end

  def HAS
    {
      rate: rate,
      rate_basis: rate_basis,
      currency: currency_id,
      hw_threshold: hw_threshold,
      hw_rate_basis: hw_rate_basis,
      min: min,
      range: range
    }.compact.with_indifferent_access
  end

end
