# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_nexus, class: "Legacy::Nexus" do
    name { "Gothenburg" }
    latitude { "57.694253" }
    longitude { "11.854048" }
    association :organization, factory: :organizations_organization
    association :country, factory: :legacy_country

    trait :segot do
      name { "Gothenburg" }
      locode { "SEGOT" }
      latitude { "57.694253" }
      longitude { "11.854048" }
      association :country, factory: :country_se
    end

    trait :cnsha do
      name { "Shanghai" }
      locode { "CNSHA" }
      latitude { "31.2231338" }
      longitude { "120.9162975" }
      association :country, factory: :country_cn
    end

    trait :deham do
      name { "Hamburg" }
      locode { "DEHAM" }
      latitude { "53.55" }
      longitude { "9.927" }
      association :country, factory: :country_de
    end

    trait :gbfxt do
      name { "Felixstowe" }
      locode { "GBFXT" }
      latitude { "51.96" }
      longitude { "1.3277" }
      association :country, factory: :country_uk
    end

    factory :gothenburg_nexus, traits: [:segot]
    factory :shanghai_nexus, traits: [:cnsha]
    factory :hamburg_nexus, traits: [:deham]
    factory :felixstowe_nexus, traits: [:gbfxt]
  end
end

def factory_nexus_from_locode(locode:, organization:)
  nexus = Legacy::Nexus.find_by(locode: locode, organization: organization)
  nexus || if locode && %w[segot cnsha deham gbfxt].include?(locode.downcase)
             FactoryBot.build(:legacy_nexus, locode.downcase.to_sym, organization: organization)
           else
             FactoryBot.build(:legacy_nexus, locode: locode, organization: organization)
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
