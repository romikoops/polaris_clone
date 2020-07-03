# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_nexus, class: 'Legacy::Nexus' do
    name { 'Gothenburg' }
    latitude { '57.694253' }
    longitude { '11.854048' }
    association :organization, factory: :organizations_organization
    association :country, factory: :legacy_country

    trait :gothenburg do
      name { 'Gothenburg' }
      locode { 'SEGOT' }
      latitude { '57.694253' }
      longitude { '11.854048' }
      association :country, factory: :country_se
    end

    trait :shanghai do
      name { 'Shanghai' }
      locode { 'CNSHG' }
      latitude { '31.2231338' }
      longitude { '120.9162975' }
      association :country, factory: :country_cn
    end

    trait :hamburg do
      name { 'Hamburg' }
      latitude { '53.55' }
      longitude { '9.927' }
      association :country, factory: :country_de
    end

    trait :felixstowe do
      name { 'Felixstowe' }
      latitude { '51.96' }
      longitude { '1.3277' }
      association :country, factory: :country_uk
    end

    factory :gothenburg_nexus, traits: [:gothenburg]
    factory :shanghai_nexus, traits: [:shanghai]
    factory :hamburg_nexus, traits: [:hamburg]
    factory :felixstowe_nexus, traits: [:felixstowe]
  end
end

# == Schema Information
#
# Table name: nexuses
#
#  id              :bigint           not null, primary key
#  latitude        :float
#  locode          :string
#  longitude       :float
#  name            :string
#  photo           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  country_id      :integer
#  organization_id :uuid
#  sandbox_id      :uuid
#  tenant_id       :integer
#
# Indexes
#
#  index_nexuses_on_organization_id  (organization_id)
#  index_nexuses_on_sandbox_id       (sandbox_id)
#  index_nexuses_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
