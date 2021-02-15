# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "Pricing .insert" do
  it "returns correct stats and creates correct data" do
    aggregate_failures do
      stats = described_class.insert(options)
      itinerary = Legacy::Itinerary.find_by(
        name: "Gothenburg - Shanghai", mode_of_transport: "ocean", transshipment: nil
      )
      expect(itinerary.slice(:name, :mode_of_transport).values).to eq(["Gothenburg - Shanghai", "ocean"])
      expect(itinerary.map_data[0][:origin]).to eq itinerary.stops[0].hub.lng_lat_array
      expect(itinerary.map_data[0][:destination]).to eq itinerary.stops[1].hub.lng_lat_array
      expect(Legacy::Stop.pluck(:itinerary_id)).to include(itinerary.id)
      pricings = ::Pricings::Pricing.all
      expect(stats).to eq(expected_stats)
      dates = pricings.pluck(:effective_date, :expiration_date)
      expect(dates).to match_array(expected_dates)
      expect(Legacy::TransitTime.count).to eq(2)
      expect(Legacy::ChargeCategory.where(code: %w[transit_time transshipment]).count).to be_zero
      pricing_details = ::Pricings::Fee.where(pricing: pricings)
      pricing_details_values = pricing_details.joins(:rate_basis).pluck(
        :rate,
        "pricings_rate_bases.external_code",
        :min,
        :range,
        :currency_name
      )
      expect(pricing_details_values).to match_array(expected_pricing_details_values)
    end
  end
end

RSpec.describe ExcelDataServices::Inserters::Pricing do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:itineraries) do
    [
      FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization),
      FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization, transshipment: "ZACPT")
    ]
  end
  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization)
  end
  let(:options) { {organization: organization, data: input_data, options: {}} }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    ::Organizations.current_id = organization.id
  end

  describe ".insert" do
    let(:input_data) { FactoryBot.build(:excel_data_restructured_correct_pricings_one_fee_col_and_ranges) }

    context "with overlap case: no_old_record" do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 11, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"]
        ]
      end

      context "with scope attribute 'base_pricing' set to >>> true <<<" do
        let!(:expected_stats) do
          {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
           "pricings/pricings": {number_created: 22, number_deleted: 0, number_updated: 2},
           "pricings/fees": {number_created: 29, number_deleted: 0, number_updated: 0},
           errors: []}
        end

        include_examples "Pricing .insert"
      end
    end

    context "with overlap case: new_starts_after_old_and_stops_at_or_after_old" do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 11, 15, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 1), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.1111e4, "PER_CONTAINER", nil, [], "EUR"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"]
        ]
      end

      context "with scope attribute 'base_pricing' set to >>> true <<<" do
        let!(:pricings) do
          [
            FactoryBot.create(:pricings_pricing,
              wm_rate: 0.1e4,
              effective_date: DateTime.new(2018, 3, 1),
              expiration_date: DateTime.new(2019, 3, 16, 23, 59, 59),
              organization: organization,
              load_type: "container",
              cargo_class: "fcl_20",
              user_id: nil,
              itinerary: itineraries.first,
              tenant_vehicle: tenant_vehicle,
              fee_attrs: {rate: 1111, rate_basis: :per_container_rate_basis, min: nil})
          ]
        end
        let!(:expected_stats) do
          {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
           "pricings/pricings": {number_created: 22, number_deleted: 0, number_updated: 3},
           "pricings/fees": {number_created: 29, number_deleted: 0, number_updated: 0},
           errors: []}
        end

        include_examples "Pricing .insert"
      end
    end

    context "with overlap case: no_overlap" do
      let!(:expected_dates) do
        [
          [DateTime.new(2019, 6, 20), DateTime.new(2019, 7, 20, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 11, 15, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.11e2, "PER_WM", nil, [], "EUR"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"]
        ]
      end

      context "with scope attribute 'base_pricing' set to >>> true <<<" do
        let!(:pricings) do
          [
            FactoryBot.create(:pricings_pricing,
              wm_rate: 0.1e4,
              effective_date: DateTime.new(2019, 6, 20),
              expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
              organization: organization,
              cargo_class: "lcl",
              load_type: "cargo_item",
              user_id: nil,
              itinerary: itineraries.first,
              tenant_vehicle: tenant_vehicle,
              fee_attrs: {rate_basis: :per_wm_rate_basis, rate: 11, min: nil})
          ]
        end
        let!(:expected_stats) do
          {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
           "pricings/pricings": {number_created: 22, number_deleted: 0, number_updated: 2},
           "pricings/fees": {number_created: 29, number_deleted: 0, number_updated: 0},
           errors: []}
        end

        include_examples "Pricing .insert"
      end
    end

    context "with overlap case: new_is_covered_by_old" do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 11, 15, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2019, 3, 29), DateTime.new(2019, 7, 20, 23, 59, 59)],
          [DateTime.new(2017, 6, 1), DateTime.new(2018, 3, 10, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.11e2, "PER_WM", nil, [], "EUR"],
          [0.11e2, "PER_WM", nil, [], "EUR"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"]
        ]
      end

      context "with scope attribute 'base_pricing' set to >>> true <<<" do
        let!(:pricings) do
          [
            FactoryBot.create(:pricings_pricing,
              wm_rate: 0.1e4,
              effective_date: DateTime.new(2017, 6, 1),
              expiration_date: DateTime.new(2019, 7, 20, 23, 59, 59),
              organization: organization,
              cargo_class: "lcl",
              load_type: "cargo_item",
              user_id: nil,
              itinerary: itineraries.first,
              tenant_vehicle: tenant_vehicle,
              fee_attrs: {rate_basis: :per_wm_rate_basis, rate: 11, min: nil})
          ]
        end
        let!(:expected_stats) do
          {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
           "pricings/pricings": {number_created: 23, number_deleted: 0, number_updated: 7},
           "pricings/fees": {number_created: 29, number_deleted: 0, number_updated: 0},
           errors: []}
        end

        include_examples "Pricing .insert"
      end
    end

    context "with overlap case: new_starts_before_old_and_stops_before_old_ends" do
      let!(:expected_dates) do
        [
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 11, 15, 23, 59, 59)],
          [DateTime.new(2018, 11, 15), DateTime.new(2018, 11, 30, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2018, 11, 14, 23, 59, 59)],
          [DateTime.new(2019, 3, 17), DateTime.new(2019, 3, 28, 23, 59, 59)],
          [DateTime.new(2018, 12, 1), DateTime.new(2019, 3, 16, 23, 59, 59)],
          [DateTime.new(2018, 3, 11), DateTime.new(2018, 3, 14, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)],
          [DateTime.new(2018, 3, 15), DateTime.new(2019, 3, 17, 23, 59, 59)]
        ]
      end
      let!(:expected_pricing_details_values) do
        [
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.17e2, "PER_WM", 0.17e2, [], "USD"],
          [0.5e3, "PER_WM", 0.5e3, [], "USD"],
          [0.2e2, "PER_WM", 0.2e2, [{"max" => 100, "min" => 0, "rate" => 20}, {"max" => 500, "min" => 101,
                                                                               "rate" => 25}], "USD"],
          [0.2e1, "PER_WM", 0.2e1, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"],
          [0.1234e4, "PER_CONTAINER", 0.1234e4, [], "USD"]
        ]
      end

      context "with scope attribute 'base_pricing' set to >>> true <<<" do
        let!(:pricings) do
          [
            FactoryBot.create(:pricings_pricing,
              wm_rate: 0.1e4,
              effective_date: DateTime.new(2018, 3, 16),
              expiration_date: DateTime.new(2019, 3, 20, 23, 59, 59),
              organization: organization,
              cargo_class: "lcl",
              load_type: "cargo_item",
              user_id: nil,
              itinerary: itineraries.first,
              tenant_vehicle: tenant_vehicle,
              fee_attrs: {rate_basis: :per_wm_rate_basis, rate: 11, min: nil})
          ]
        end
        let!(:expected_stats) do
          {"legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
           "pricings/pricings": {number_created: 22, number_deleted: 1, number_updated: 5},
           "pricings/fees": {number_created: 29, number_deleted: 1, number_updated: 0},
           errors: []}
        end

        include_examples "Pricing .insert"
      end
    end
  end

  context "when locode is present instead of the name" do
    let(:input_data) { FactoryBot.build(:excel_data_restructured, :only_locode_pricings_one_fee_col_and_ranges) }
    let(:expected_stats) do
      {errors: [],
       "legacy/itineraries": {number_created: 0, number_updated: 0, number_deleted: 0},
       "pricings/pricings": {number_created: 1, number_updated: 0, number_deleted: 0},
       "pricings/fees": {number_created: 1, number_updated: 0, number_deleted: 0}}
    end
    let(:options) { {organization: organization, data: input_data, options: {}} }

    it "finds the hub by the locode and inserts successfully" do
      expect(described_class.insert(options)).to eq(expected_stats)
    end
  end
end
