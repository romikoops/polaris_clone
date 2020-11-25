FactoryBot.define do
  factory :journey_route_point, class: "Journey::RoutePoint" do
    transient do
      latitude { 57.694253 }
      longitude { 11.854048 }
    end

    coordinates { RGeo::Cartesian.factory.point(longitude, latitude) }
    function { "ocean" }
    name { "Hamburg" }
  end
end
