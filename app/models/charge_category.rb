# frozen_string_literal: true

class ChargeCategory < ApplicationRecord
  has_many :charges
  belongs_to :tenant, optional: true

  validates :name, :code, presence: true
  validates :code, is_model: true, unless: ->(obj) { obj.cargo_unit_id.nil? }

  def self.grand_total
    find_or_create_by(code: 'grand_total', name: 'Grand Total')
  end

  def self.base_node
    find_or_create_by(code: 'base_node', name: 'Base Node')
  end

  def self.update_names
    LocalCharge.pluck(:fees).reject(&:empty?).each do |fees|
      fees.values.each do |fee|
        from_fee(fee) unless fee['key'].blank?
      end
    end

    [
      { code: 'HAS', name: 'Heavy Weight Surcharge' },
      { code: 'EBS', name: 'Emergency Bunker Surcharge' },
      { code: 'XAS', name: 'XAS' },
      { code: 'LSS', name: 'Low Sulphur Surcharge' },
      { code: 'BAS', name: 'Basic Ocean Freight' }
    ].each do |attributes|
      (find_by(attributes.slice(:code)) || new).update(attributes)
    end

    TruckingPricing.pluck(:fees).reject(&:empty?).each do |fees|
      fees.values.each do |fee|
        from_fee(fee)
      end
    end
  end

  def self.from_code(code, tenant_id)
    tenant_charge_category = find_by(code: code, tenant_id: tenant_id)
    return tenant_charge_category unless tenant_charge_category.nil?
    find_by_code(code) ||
      find_or_create_by(
        code: code,
        name: code.to_s.humanize.split(' ').map(&:capitalize).join(' ')
      )
  end

  def self.from_fee(fee)
    code = fee['key']
    name = fee.fetch('name') do
      fee['key'].to_s.humanize.split(' ').map(&:capitalize).join(' ')
    end

    (find_by(code: code) || new).update!(name: name, code: code)
  end

  def cargo_unit
    return nil if cargo_unit_id.nil?

    klass = code.camelize.safe_constantize
    klass.where(id: cargo_unit_id).first
  end
end
