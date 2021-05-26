# frozen_string_literal: true

FactoryBot.define do
  factory :journey_result, class: "Journey::Result" do
    association :result_set, factory: :journey_result_set
    expiration_date { 4.weeks.from_now }
    issued_at { Time.zone.now }
    created_at { Time.zone.now }
    transient do
      sections { 1 }
      line_item_set_count { 1 }
    end

    route_sections do
      Array.new(sections) do
        association :journey_route_section, result: instance
      end
    end

    line_item_sets do
      Array.new(line_item_set_count) do
        association :journey_line_item_set, result: instance
      end
    end

    trait :empty do
      line_item_set_count { 0 }
    end
  end
end
