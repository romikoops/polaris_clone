# frozen_string_literal: true

class Remark < Legacy::Remark
  belongs_to :organization, class_name: "Organizations::Organization"
end

# == Schema Information
#
# Table name: remarks
#
#  id              :bigint           not null, primary key
#  body            :string
#  category        :string
#  order           :integer
#  subcategory     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :bigint
#
# Indexes
#
#  index_remarks_on_organization_id  (organization_id)
#  index_remarks_on_sandbox_id       (sandbox_id)
#  index_remarks_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
