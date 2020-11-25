FactoryBot.define do
  factory :journey_query, class: "Journey::Query" do
    transient do
      origin_latitude { 53.545322 }
      origin_longitude { 9.9986522 }
      destination_latitude { 31.1443485 }
      destination_longitude { 121.8060843 }
    end

    association :company, factory: :companies_company
    association :creator, factory: :organizations_user
    association :client, factory: :organizations_user

    source_id { SecureRandom.uuid }
    origin { "20457, Hamburg" }
    origin_coordinates { RGeo::Cartesian.factory.point(origin_longitude, origin_latitude) }
    destination { "Shanghai Airport" }
    destination_coordinates { RGeo::Cartesian.factory.point(origin_longitude, origin_latitude) }
    cargo_ready_date { Time.zone.tomorrow }
    delivery_date { Time.zone.today + 3.weeks }
    customs { false }
    insurance { false }
  end
end
