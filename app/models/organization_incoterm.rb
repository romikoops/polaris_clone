# frozen_string_literal: true

class OrganizationIncoterm < ApplicationRecord
  self.table_name = 'tenant_incoterms'
  belongs_to :organization, class_name: 'Organizations::Organization'
  belongs_to :incoterm
end

# == Schema Information
#
# Table name: tenant_incoterms
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  incoterm_id     :integer
#  organization_id :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_tenant_incoterms_on_organization_id  (organization_id)
#  index_tenant_incoterms_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
