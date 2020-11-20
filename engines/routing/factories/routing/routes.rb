# frozen_string_literal: true

FactoryBot.define do
  factory :routing_route, class: "Routing::Route" do
    time_factor { 5 }
    price_factor { 5 }
    allowed_cargo { 3 }
    mode_of_transport { 1 }

    transient do
      origin_location { :hamburg }
      destination_location { :shanghai }
      all_mots { false }
    end

    trait :freight do
      before(:create) do |route, evaluator|
        unless route.origin
          route.origin = create(:routing_location, evaluator.origin_location, all_mots: evaluator.all_mots)
        end
        unless route.destination
          route.destination = create(:routing_location, evaluator.destination_location, all_mots: evaluator.all_mots)
        end
        unless route.origin_terminal
          route.origin_terminal = route.origin.terminals.find_by(mode_of_transport: route.mode_of_transport)
        end
        unless route.destination_terminal
          route.destination_terminal = route.destination.terminals.find_by(mode_of_transport: route.mode_of_transport)
        end
      end
    end

    trait :on do
      after(:build) do |route, evaluator|
        route.destination_terminal_id = nil
        unless route.origin
          route.origin = build(:routing_location, evaluator.origin_location, all_mots: evaluator.all_mots)
        end
        unless route.destination
          route.destination = build(:routing_location, evaluator.destination_location, all_mots: evaluator.all_mots)
        end
        route.origin_terminal = route.origin.terminals.first unless route.origin_terminal
      end
    end

    trait :pre do
      after(:build) do |route, evaluator|
        route.origin_terminal_id = nil
        unless route.origin
          route.origin = build(:routing_location, evaluator.origin_location, all_mots: evaluator.all_mots)
        end
        unless route.destination
          route.destination = build(:routing_location, evaluator.destination_location, all_mots: evaluator.all_mots)
        end
        route.destination_terminal = route.destination.terminals.first unless route.destination_terminal
      end
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

    factory :pre_carriage_route, traits: %i[carriage pre]
    factory :on_carriage_route, traits: %i[carriage on]
    factory :ocean_route, traits: %i[ocean freight]
    factory :air_route, traits: %i[air freight]
    factory :rail_route, traits: %i[rail freight]
    factory :truck_route, traits: %i[truck freight]
    factory :freight_route, traits: [:freight]
  end
end

# == Schema Information
#
# Table name: routing_routes
#
#  id                      :uuid             not null, primary key
#  allowed_cargo           :integer          default(0), not null
#  mode_of_transport       :integer          default(NULL), not null
#  price_factor            :decimal(, )
#  time_factor             :decimal(, )
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destination_id          :uuid
#  destination_terminal_id :uuid
#  origin_id               :uuid
#  origin_terminal_id      :uuid
#
# Indexes
#
#  routing_routes_index  (origin_id,destination_id,origin_terminal_id,destination_terminal_id,mode_of_transport) UNIQUE
#
