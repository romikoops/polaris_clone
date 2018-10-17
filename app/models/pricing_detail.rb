# frozen_string_literal: true

class PricingDetail < ApplicationRecord
  has_paper_trail
  belongs_to :tenant
  belongs_to :priceable, polymorphic: true

  def as_json(options={})
    new_options = options.reverse_merge(
      methods: shipping_type, only: []
    )
    super(new_options)
  end

  def to_fee
    {
      rate:          rate,
      rate_basis:    rate_basis,
      currency:      currency_name,
      hw_threshold:  hw_threshold,
      hw_rate_basis: hw_rate_basis,
      min:           min,
      range:         range
    }.compact.with_indifferent_access
  end

  def method_missing(method_name, *args)
    if method_name == shipping_type.to_sym
      to_fee
    else
      super
    end
  end

  def respond_to_missing?(method_name, *args)
    if method_name == shipping_type.to_sym
      true
    else
      super
    end
  end
end
