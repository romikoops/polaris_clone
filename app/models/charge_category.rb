# frozen_string_literal: true

class ChargeCategory < Legacy::ChargeCategory
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
