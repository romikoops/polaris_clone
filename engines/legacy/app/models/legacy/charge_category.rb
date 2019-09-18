# frozen_string_literal: true

module Legacy
  class ChargeCategory < ApplicationRecord
    self.table_name = 'charge_categories'
    has_many :charges
    belongs_to :tenant, class_name: 'Legacy::Tenant', optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

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
  end
end

# == Schema Information
#
# Table name: charge_categories
#
#  id            :bigint(8)        not null, primary key
#  name          :string
#  code          :string
#  cargo_unit_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tenant_id     :integer
#  sandbox_id    :uuid
#
