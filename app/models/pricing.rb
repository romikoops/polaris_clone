# frozen_string_literal: true

class Pricing < ApplicationRecord
  belongs_to :itinerary
  belongs_to :tenant
  belongs_to :transport_category
  belongs_to :tenant_vehicle
  belongs_to :user, optional: true
  has_many :pricing_details, as: :priceable, dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy
  has_many :pricing_requests, dependent: :destroy

  delegate :load_type, to: :transport_category
  delegate :cargo_class, to: :transport_category
  scope :for_load_type, ->(load_type) { joins(:transport_category).where('transport_categories.load_type': load_type) }

  self.per_page = 12

  def as_json(options={})
    new_options = options.reverse_merge(
      methods: %i(data exceptions load_type cargo_class carrier service_level),
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

  def carrier
    tenant_vehicle&.carrier&.name
  end

  def service_level
    tenant_vehicle&.name
  end

  def has_requests(user_id)
    pricing_requests.exists?(user_id: user_id)
  end

  def duplicate_for_user(user_id)
      pricing_to_update = Pricing.new
      new_pricing_data = self.as_json
      new_pricing_data.delete('controller')
      new_pricing_data.delete('subdomain_id')
      new_pricing_data.delete('action')
      new_pricing_data.delete('id')
      new_pricing_data.delete('created_at')
      new_pricing_data.delete('updated_at')
      new_pricing_data.delete('load_type')
      new_pricing_data.delete('cargo_class')
      new_pricing_data['user_id'] = user_id
      pricing_details = new_pricing_data.delete('data')
      pricing_exceptions = new_pricing_data.delete('exceptions')
      pricing_to_update.update(new_pricing_data)
      pricing_details.each do |shipping_type, pricing_detail_data|
        currency = pricing_detail_data.delete('currency')
        pricing_detail_params = pricing_detail_data.merge(
          shipping_type: shipping_type,
          tenant:        self.tenant
        )
        range = pricing_detail_params.delete('range')
        pricing_detail = pricing_to_update.pricing_details.find_or_create_by(
          shipping_type: shipping_type,
          tenant:        self.tenant
        )
        pricing_detail.update!(pricing_detail_params)
        pricing_detail.update!(range: range, currency_name: currency)
      end

    # new_pricing = self.dup
    # new_pricing.save!
    # pricing_details.each do |detail|
    #   new_detail = detail.dup
    #   new_detail.priceable_id = new_pricing.id
    #   new_detail.save!
    # end
  end
end
