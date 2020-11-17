FactoryBot.define do
  factory :routing_terminal, class: 'Routing::Terminal' do
    association :location, factory: :routing_location
    center { FactoryBot.build(:routing_point, lat: 53.558572, lng: 9.9278215) }
    terminal_code { 'DEHAMPS' }
    default { false }
    mode_of_transport { 1 }

    trait :ocean do
      mode_of_transport { 1 }
    end

    trait :air do
      mode_of_transport { 2 }
    end
    
    trait :rail do
      mode_of_transport { 3 }
    end

    trait :truck do
      mode_of_transport { 4 }
    end

    trait :carriage do
      mode_of_transport { 5 }
    end
    trait :hamburg do
      terminal_code { 'DEHAM1' }
      center { FactoryBot.build(:routing_point, lat: 53.558572, lng: 9.9278215) }
    end

    trait :shanghai do
      terminal_code { 'CNSHA1' }
      center { FactoryBot.build(:routing_point, lat: 31.2231338, lng: 120.9162975) }
    end

    trait :felixstowe do
      terminal_code { 'GBFXT1' }
      center { FactoryBot.build(:routing_point, lat: 51.966, lng: 1.3277) }
    end

    trait :gothenburg do
      terminal_code { 'SEGOT1' }
      center { FactoryBot.build(:routing_point, lat: 57.694253, lng: 11.854048) }
    end

    trait :rotterdam do
      terminal_code { 'NLRTM1' }
      center { FactoryBot.build(:routing_point, lat: 51.9280573, lng: 4.4203672) }
    end

    trait :ningbo do
      terminal_code { 'CNNBO1' }
      center { FactoryBot.build(:routing_point, lat: 29.8700041, lng: 121.4318779) }
    end

    trait :veracruz do
      terminal_code { 'MXVER1' }
      center { FactoryBot.build(:routing_point, lat: 19.1787535, lng: -96.2463566) }
    end

    factory :ocean_terminal, traits: [:ocean]
    factory :air_terminal, traits: [:air]
    factory :rail_terminal, traits: [:rail]
    factory :truck_terminal, traits: [:truck]
    factory :carriage_terminal, traits: [:carriage]
    factory :hamburg_terminal, traits: [:hamburg]
    factory :shanghai_terminal, traits: [:shanghai]
    factory :felixstowe_terminal, traits: [:felixstowe]
    factory :gothenburg_terminal, traits: [:gothenburg]
    factory :rotterdam_terminal, traits: [:rotterdam]
    factory :ningbo_terminal, traits: [:ningbo]
    factory :veracruz_terminal, traits: [:veracruz]
  end
end

# == Schema Information
#
# Table name: routing_terminals
#
#  id                :uuid             not null, primary key
#  center            :geometry         geometry, 0
#  default           :boolean          default(FALSE)
#  mode_of_transport :integer          default(NULL)
#  terminal_code     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  location_id       :uuid
#
# Indexes
#
#  index_routing_terminals_on_center  (center)
#
