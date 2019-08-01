FactoryBot.define do
  factory :routing_route, class: 'Routing::Route' do
    association :origin, factory: :routing_location
    association :destination, factory: :routing_location
    time_factor { 5 }
    price_factor { 5 }
    allowed_cargo { 3 }
    trait :gothenburg_shanghai do
      association :origin, factory: :gothenburg_location
      association :destination, factory: :shanghai_location
    end

    trait :shanghai_gothenburg do
      association :origin, factory: :shanghai_location
      association :destination, factory: :gothenburg_location
    end

    trait :felixstowe_shanghai do
      association :origin, factory: :felixstowe_location
      association :destination, factory: :shanghai_location
    end

    trait :shanghai_felixstowe do
      association :origin, factory: :shanghai_location
      association :destination, factory: :felixstowe_location
    end

    trait :hamburg_shanghai do
      association :origin, factory: :hamburg_location
      association :destination, factory: :shanghai_location
    end

    trait :shanghai_hamburg do
      association :origin, factory: :shanghai_location
      association :destination, factory: :hamburg_location
    end

    factory :gothenburg_shanghai_route, traits: [:gothenburg_shanghai]
    factory :shanghai_gothenburg_route, traits: [:shanghai_gothenburg]
    factory :felixstowe_shanghai_route, traits: [:felixstowe_shanghai]
    factory :shanghai_felixstowe_route, traits: [:shanghai_felixstowe]
    factory :hamburg_shanghai_route, traits: [:hamburg_shanghai]
    factory :shanghai_hamburg_route, traits: [:shanghai_hamburg]
  end
end
