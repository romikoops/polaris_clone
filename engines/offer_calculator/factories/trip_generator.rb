# frozen_string_literal: true

FactoryBot.define do
  factory :trip_generator, class: "Hash" do
    # skip_create

    tenant { FactoryBot.create(:organizations_organization) }
    itineraries { [FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization)] }
    tenant_vehicles { [FactoryBot.create(:legacy_tenant_vehicle, organization: organization)] }
    load_type { "cargo_item" }
    days { [1] }
    trips do
      days.product(tenant_vehicles, itineraries)
        .map do |period, tenant_vehicle, itinerary|
        FactoryBot.create(:trip_with_layovers,
          itinerary: itinerary,
          load_type: load_type,
          tenant_vehicle: tenant_vehicle,
          closing_date: Time.zone.now + period.days,
          start_date: Time.zone.now + (5 + period).days,
          end_date: Time.zone.now + (25 + period).days)
      end
    end
    initialize_with { attributes }
  end
end
