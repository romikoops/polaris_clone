# frozen_string_literal: true

module Legacy
  class ChargeCategory < ApplicationRecord
    self.table_name = "charge_categories"
    has_many :charges
    belongs_to :organization, class_name: "Organizations::Organization", optional: true
    validates :name, :code, presence: true
    validates_uniqueness_of :name, scope: %i[code organization_id cargo_unit_id]

    before_validation :downcase_code

    def self.from_code(code:, organization_id: nil, name: nil, cargo_unit_id: nil)
      name ||= code
      code = code.to_s.downcase
      tenant_charge_category = find_by(code: code, organization_id: organization_id, cargo_unit_id: cargo_unit_id)
      return tenant_charge_category unless tenant_charge_category.nil?

      find_or_create_by(
        code: code,
        name: name,
        cargo_unit_id: cargo_unit_id,
        organization_id: organization_id
      )
    end

    def cargo_unit
      return nil if cargo_unit_id.nil?

      klass = "Legacy::#{code.camelize}".safe_constantize
      klass.find_by(id: cargo_unit_id)
    end

    private

    def downcase_code
      code.downcase!
    end
  end
end

# == Schema Information
#
# Table name: charge_categories
#
#  id              :bigint           not null, primary key
#  code            :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cargo_unit_id   :integer
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_charge_categories_on_cargo_unit_id    (cargo_unit_id)
#  index_charge_categories_on_code             (code)
#  index_charge_categories_on_organization_id  (organization_id)
#  index_charge_categories_on_sandbox_id       (sandbox_id)
#  index_charge_categories_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
