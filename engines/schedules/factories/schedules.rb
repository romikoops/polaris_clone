# frozen_string_literal: true

FactoryBot.define do
  factory :schedules_schedule, class: "Schedules::Schedule" do
    association :organization, factory: :organizations_organization

    voyage_code { "12345" }
    vessel_name { "saco" }
    vessel_code { "ab123" }
    origin { "20457, hamburg" }
    destination { "shanghai airport" }
    origin_departure { Time.zone.tomorrow }
    destination_arrival { Time.zone.today + 3.weeks }
    closing_date { Time.zone.tomorrow + 3.weeks }
    carrier { "msc" }
    service { "standard" }
    created_at { DateTime.now.change(usec: 0) }
  end
end
