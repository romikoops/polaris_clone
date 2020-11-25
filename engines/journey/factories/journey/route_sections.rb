FactoryBot.define do
  factory :journey_route_section, class: "Journey::RouteSection" do
    association :from, factory: :journey_route_point
    association :to, factory: :journey_route_point
    carrier { "MSC" }
    mode_of_transport { :ocean }
    service { "standard" }
    sequence(:order) { |n| n }
  end
end
