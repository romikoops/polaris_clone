# frozen_string_literal: true

module Legacy
  class ChargeCategory < ApplicationRecord
    self.table_name = 'charge_categories'
    has_many :charges
    belongs_to :tenant, class_name: 'Legacy::Tenant', optional: true

    def self.grand_total
      find_or_create_by(code: 'grand_total', name: 'Grand Total')
    end

    def self.base_node
      find_or_create_by(code: 'base_node', name: 'Base Node')
    end

    def self.grand_total
      find_or_create_by(code: 'grand_total', name: 'Grand Total')
    end
  
    def self.base_node
      find_or_create_by(code: 'base_node', name: 'Base Node')
    end

    def self.from_code(code:, tenant_id: nil, name: nil, sandbox: nil)
      name ||= code
      code = code.to_s.downcase
      tenant_charge_category = find_by(code: code, tenant_id: tenant_id, sandbox_id: sandbox&.id)
      return tenant_charge_category unless tenant_charge_category.nil?

      find_or_create_by(
        code: code,
        name: name,
        tenant_id: tenant_id,
        sandbox_id: sandbox&.id
      )
    end
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
#  index_charge_categories_on_sandbox_id  (sandbox_id)
#  index_charge_categories_on_tenant_id   (tenant_id)
#
