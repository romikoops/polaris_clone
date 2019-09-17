FactoryBot.define do
  factory :routing_route, class: 'Routing::Route' do
    time_factor { 5 }
    price_factor { 5 }
    allowed_cargo { 3 }
    mode_of_transport { 1 }

    transient do
      origin_location { :hamburg }
      destination_location { :shanghai }
      all_mots { false }
    end
    after(:build) do |route, evaluator|
      route.origin = create(:routing_location, evaluator.origin_location, all_mots: evaluator.all_mots) unless route.origin
      route.destination = create(:routing_location, evaluator.destination_location, all_mots: evaluator.all_mots) unless route.destination
      route.origin_terminal = route.origin.terminals.find_by(mode_of_transport: route.mode_of_transport) unless route.origin_terminal
      route.destination_terminal = route.destination.terminals.find_by(mode_of_transport: route.mode_of_transport) unless route.destination_terminal
    end

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
  end
end
