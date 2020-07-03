# frozen_string_literal: true

FactoryBot.define do
  factory :companies_membership, class: 'Companies::Membership' do
    association :company, factory: :companies_company
    member { nil }
  end
end

# == Schema Information
#
# Table name: companies_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :uuid
#  member_id   :uuid
#
# Indexes
#
#  index_companies_memberships_on_company_id                 (company_id)
#  index_companies_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies_companies.id)
#
