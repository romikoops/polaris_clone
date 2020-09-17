FactoryBot.define do
  factory :organizations_domain, class: "Organizations::Domain" do
    domain { "MyString" }
    organization { nil }
    default { false }
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
