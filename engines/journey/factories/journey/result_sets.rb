FactoryBot.define do
  factory :journey_result_set, class: "Journey::ResultSet" do
    association :query, factory: :journey_query
  end
end
