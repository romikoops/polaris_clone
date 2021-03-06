# frozen_string_literal: true

FactoryBot.define do
  factory :companies_company, class: "Companies::Company" do
    association :organization, factory: :organizations_organization
    sequence(:name) { |n| "company#{n}" }
    sequence(:payment_terms) { "Some quotation payment terms" }
    sequence(:vat_number) { |n| "DE-VATNUMBER#{n}" }

    trait :with_member do
      transient do
        member { nil }
      end

      after(:create) do |company, evaluator|
        FactoryBot.create(:companies_membership, company: company, client: evaluator.member) if evaluator.member
      end
    end
  end
end

# == Schema Information
#
# Table name: companies_companies
#
#  id              :uuid             not null, primary key
#  deleted_at      :datetime
#  email           :string
#  name            :string
#  phone           :string
#  vat_number      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_companies_companies_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
