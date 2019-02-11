FactoryBot.define do
  factory :locations_name, class: 'Locations::Name' do
    language 'en'
    osm_id "-2222"
    street nil
    country nil
    city 'Shanghai'
    country_code nil
    display_name nil
    name nil
    point '01010000007182250DA47B5E406EC328081E453F40'
    postal_code nil
    osm_type nil
    state nil
    county nil

    trait :reindex do
      after(:create) do |name, _evaluator|
        name.reindex(refresh: true)
      end
    end
  end
end
