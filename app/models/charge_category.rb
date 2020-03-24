# frozen_string_literal: true

class ChargeCategory < Legacy::ChargeCategory
  has_many :charges
  belongs_to :tenant, optional: true
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

  validates :name, :code, presence: true
  validates :code, is_model: true, unless: ->(obj) { obj.cargo_unit_id.nil? }
  validates_uniqueness_of :name, scope: %i(code tenant_id cargo_unit_id)

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

  def self.from_code(code:, tenant_id: nil, name: nil, sandbox: nil)
    name ||= code
    code = code.to_s.downcase
    tenant_charge_category = find_by(code: code, tenant_id: tenant_id, sandbox: sandbox)
    return tenant_charge_category unless tenant_charge_category.nil?

    find_or_create_by(
      code: code,
      name: name,
      tenant_id: tenant_id,
      sandbox: sandbox
    )
  end

  def self.from_fee(fee)
    code = fee['key'].downcase
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

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint           not null, primary key
#  code          :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cargo_unit_id :integer
#  sandbox_id    :uuid
#  tenant_id     :integer
#
# Indexes
#
#  index_charge_categories_on_cargo_unit_id  (cargo_unit_id)
#  index_charge_categories_on_code           (code)
#  index_charge_categories_on_sandbox_id     (sandbox_id)
#  index_charge_categories_on_tenant_id      (tenant_id)
#
