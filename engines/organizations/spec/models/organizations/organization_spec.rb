require "rails_helper"

module Organizations
  RSpec.describe Organization, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end

# == Schema Information
#
# Table name: organizations_organizations
#
#  id                      :uuid             not null, primary key
#  slug                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  organization_id         :bigint
#  tenants_organization_id :uuid
#
# Indexes
#
#  index_organizations_organizations_on_organization_id          (organization_id)
#  index_organizations_organizations_on_slug                     (slug) UNIQUE
#  index_organizations_organizations_on_tenants_organization_id  (tenants_organization_id)
#
