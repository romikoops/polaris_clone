# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_nexus, class: "Legacy::Nexus" do
    name { "Gothenburg" }
    latitude { "57.694253" }
    longitude { "11.854048" }
    association :organization, factory: :organizations_organization
    country { factory_country_from_code(code: "SE") }
    sequence(:locode) { |n| "SEG#{('A'..'Z').to_a[n % 24]}T" }

    trait :segot do
      name { "Gothenburg" }
      locode { "SEGOT" }
      latitude { "57.694253" }
      longitude { "11.854048" }
      country { factory_country_from_code(code: "SE") }
    end

    trait :cnsha do
      name { "Shanghai" }
      locode { "CNSHA" }
      latitude { "31.2231338" }
      longitude { "120.9162975" }
      country { factory_country_from_code(code: "CN") }
    end

    trait :deham do
      name { "Hamburg" }
      locode { "DEHAM" }
      latitude { "53.55" }
      longitude { "9.927" }
      country { factory_country_from_code(code: "DE") }
    end

    trait :gbfxt do
      name { "Felixstowe" }
      locode { "GBFXT" }
      latitude { "51.96" }
      longitude { "1.3277" }
      country { factory_country_from_code(code: "GB") }
    end

    factory :gothenburg_nexus, traits: [:segot]
    factory :shanghai_nexus, traits: [:cnsha]
    factory :hamburg_nexus, traits: [:deham]
    factory :felixstowe_nexus, traits: [:gbfxt]
  end
end

def factory_nexus_from_locode(locode_string:, organization:)
  existing_nexus = Legacy::Nexus.find_by(locode: locode_string, organization: organization)
  existing_nexus || if locode_string && %w[segot cnsha deham gbfxt].include?(locode_string.downcase)
                      FactoryBot.build(:legacy_nexus, locode_string.downcase.to_sym, organization: organization)
                    else
                      FactoryBot.build(:legacy_nexus, locode: locode_string, organization: organization)
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
