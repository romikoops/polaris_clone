# frozen_string_literal: true

class ChargeCategory < ApplicationRecord
  has_many :charges

  validates :name, :code, presence: true
  validates :code, is_model: true, unless: ->(obj) { obj.cargo_unit_id.nil? }

  def self.grand_total
    find_or_create_by(code: 'grand_total', name: 'Grand Total')
  end

  def self.base_node
    find_or_create_by(code: 'base_node', name: 'Base Node')
  end

  def self.update_names
    LocalCharge.pluck(:fees).reject(&:empty?).each do |fee|
      ChargeCategory.from_fee(fee)
    end
    PricingDetail.find_each do |pricing|
      fee = { 'code' => pricing.shipping_type }
      ChargeCategory.from_fee(fee)
    end
    TruckingPricing.pluck(:fees).reject(&:empty?).each do |fee|
      ChargeCategory.from_fee(fee)
    end
  end

  def self.from_code(code)
    find_by_code(code) ||
      find_or_create_by(
        code: code,
        name: code.to_s.humanize.split(' ').map(&:capitalize).join(' ')
      )
  end

  def self.from_fee(charge)
    charge_name = charge['name'] || charge['key'].to_s.humanize.split(' ').map(&:capitalize).join(' ')
    existing_charge_category = find_by(code: charge['key'])
    if existing_charge_category.nil?
      find_or_create_by(code: charge['key'], name: charge_name)
    else
      existing_charge_category.update_attributes(name: charge_name)
    end
  end

  def cargo_unit
    return nil if cargo_unit_id.nil?

    klass = code.camelize.safe_constantize
    klass.where(id: cargo_unit_id).first
  end
end
