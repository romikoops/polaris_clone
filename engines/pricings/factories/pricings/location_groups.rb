FactoryBot.define do
  factory :pricings_location_group, class: "Pricings::LocationGroup" do
    association :organization, factory: :organizations_organization
    association :nexus, factory: :legacy_nexus
    name { "GroupA" }
  end
end
