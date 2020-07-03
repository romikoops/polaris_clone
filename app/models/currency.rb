# frozen_string_literal: true

class Currency < Legacy::Currency
end

# == Schema Information
#
# Table name: currencies
#
#  id              :bigint           not null, primary key
#  base            :string
#  today           :jsonb
#  yesterday       :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_currencies_on_organization_id  (organization_id)
#  index_currencies_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
