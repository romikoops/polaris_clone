require "rails_helper"

module Organizations
  RSpec.describe Domain, type: :model do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end

# == Schema Information
#
# Table name: organizations_domains
#
#  id              :uuid             not null, primary key
#  aliases         :string           is an Array
#  default         :boolean          default(FALSE), not null
#  domain          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_domains_on_domain           (domain) UNIQUE
#  index_organizations_domains_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
