# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_type_availability, class: 'Trucking::TypeAvailability' do
    load_type  { 'cargo_item' }
    carriage   { 'pre' }
    truck_type { 'default' }
    query_method { :not_set }
    association :country, factory: :legacy_country

    transient do
      custom_truck_type { nil }
      custom_query_method { nil }
    end

    before(:create) do |availability, evaluator|
      availability.truck_type = evaluator.custom_truck_type if evaluator.custom_truck_type.present?
      availability.query_method = evaluator.custom_query_method if evaluator.custom_query_method.present?
    end

    trait :pre_carriage do
      carriage   { 'pre' }
    end
    trait :on_carriage do
      carriage   { 'on' }
    end
    trait :container do
      load_type  { 'container' }
    end
    trait :cargo_item do
      load_type  { 'cargo_item' }
    end
    trait :distance do
      query_method { :distance }
    end

    factory :cargo_item_pre_carriage, traits: %i[pre_carriage cargo_item]
    factory :container_pre_carriage, traits: %i[pre_carriage container]
    factory :cargo_item_pre_carriage_distance, traits: %i[pre_carriage cargo_item distance]
    factory :container_pre_carriage_distance, traits: %i[pre_carriage container distance]
    factory :cargo_item_on_carriage, traits: %i[on_carriage cargo_item]
    factory :container_on_carriage, traits: %i[on_carriage container]
    factory :cargo_item_on_carriage_distance, traits: %i[on_carriage cargo_item distance]
    factory :container_on_carriage_distance, traits: %i[on_carriage container distance]
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  carriage     :string
#  load_type    :string
#  query_method :integer
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_type_availabilities_on_load_type     (load_type)
#  index_trucking_type_availabilities_on_query_method  (query_method)
#  index_trucking_type_availabilities_on_sandbox_id    (sandbox_id)
#  index_trucking_type_availabilities_on_truck_type    (truck_type)
#
