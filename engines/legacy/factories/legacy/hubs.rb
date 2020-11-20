# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_hub, class: "Legacy::Hub" do
    trait :with_lat_lng do
      latitude { "57.694253" }
      longitude { "11.854048" }
    end

    name { "Gothenburg" }
    hub_type { "ocean" }
    hub_status { "active" }
    hub_code { "SEGOT" }
    free_out { false }
    association :organization, factory: :organizations_organization
    association :address, factory: :legacy_address
    association :nexus, factory: :legacy_nexus
    association :mandatory_charge, factory: :legacy_mandatory_charge

    trait :gothenburg do
      name { "Gothenburg" }
      hub_type { "ocean" }
      hub_status { "active" }
      hub_code { "SEGOT" }
      latitude { "57.694253" }
      longitude { "11.854048" }
      association :address, factory: :gothenburg_address
      association :nexus, factory: :gothenburg_nexus
    end

    trait :shanghai do
      name { "Shanghai" }
      hub_type { "ocean" }
      hub_status { "active" }
      hub_code { "CNSHA" }
      latitude { "31.2231338" }
      longitude { "120.9162975" }
      association :address, factory: :shanghai_address
      association :nexus, factory: :shanghai_nexus
    end

    trait :hamburg do
      name { "Hamburg" }
      hub_type { "ocean" }
      hub_status { "active" }
      hub_code { "DEHAM" }
      latitude { "53.55" }
      longitude { "9.927" }
      association :address, factory: :hamburg_address
      association :nexus, factory: :hamburg_nexus
    end

    trait :felixstowe do
      name { "Felixstowe" }
      hub_type { "ocean" }
      hub_status { "active" }
      hub_code { "GBFXT" }
      latitude { "51.96" }
      longitude { "1.3277" }
      association :address, factory: :felixstowe_address
      association :nexus, factory: :felixstowe_nexus
    end

    factory :gothenburg_hub, traits: [:gothenburg]
    factory :shanghai_hub, traits: [:shanghai]
    factory :hamburg_hub, traits: [:hamburg]
    factory :felixstowe_hub, traits: [:felixstowe]
    # association :mandatory_charge
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry         geometry, 4326
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  organization_id     :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  index_hubs_on_organization_id  (organization_id)
#  index_hubs_on_point            (point) USING gist
#  index_hubs_on_sandbox_id       (sandbox_id)
#  index_hubs_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
