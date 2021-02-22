# frozen_string_literal: true
FactoryBot.define do
  factory :journey_result_set, class: "Journey::ResultSet" do
    association :query, factory: :journey_query
    currency { "EUR" }
    transient do
      result_count { 1 }
    end

    results do
      Array.new(result_count) do
        association :journey_result, result_set: instance
      end
    end

    status { "completed" }
  end
end
