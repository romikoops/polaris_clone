# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RelationData do
  let(:result_frame) { described_class.new(relation: relation, period: period).frame }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:relation) { Trucking::Trucking.where(organization: organization) }
  let(:trucking_rate_count) { trucking.rates.values.flatten.count }
  let(:trucking_fee_count) { trucking.fees.keys.count }

  before do
    factory_charge_category_from(code: "trucking_#{trucking.cargo_class}", organization: organization)
    Organizations.current_id = organization.id
  end

  context "with a PER_SHIPMENT fee" do
    let!(:trucking) { FactoryBot.create(:trucking_trucking, :updated_load_meterage, organization: organization) }

    it "returns the entire trucking main rate and additional fees flattened into a data frame", :aggregate_failures do
      expected_rates = [trucking.fees.dig("PUF", "value")] + trucking.rates["kg"].map { |rate| rate["rate"]["value"] }
      expect(result_frame["context_id"].to_a).to eq([trucking.id] * (trucking_rate_count + trucking_fee_count))
      expect(result_frame["code"].to_a).to eq(["puf"] + (["trucking_lcl"] * trucking_rate_count))
      expect(result_frame["range_unit"].to_a).to eq(["shipment"] + (["kg"] * trucking_rate_count))
      expect(result_frame["rate"].to_a).to eq(expected_rates)
    end

    it "transforms the load meterage into the data frame", :aggregate_failures do
      expect(result_frame["load_meterage_ratio"].to_a.uniq).to eq([trucking.load_meterage["ratio"]])
      expect(result_frame["load_meterage_stackable_type"].to_a.uniq).to eq([trucking.load_meterage["stackable_type"]])
      expect(result_frame["load_meterage_stackable_limit"].to_a.uniq).to eq([trucking.load_meterage["stackable_limit"]])
    end
  end

  context "when the Trucking::Trucking has both 'cbm' and 'kg' based rates" do
    let!(:trucking) { FactoryBot.create(:trucking_trucking, :updated_load_meterage, :cbm_kg_rates, organization: organization) }

    it "returns the entire trucking main rate (both unit and kg rate columns) and additional fees flattened into a data frame", :aggregate_failures do
      expect(result_frame["context_id"].to_a).to eq([trucking.id] * (trucking_rate_count + trucking_fee_count))
      expect(result_frame["code"].to_a).to eq(["puf"] + (["trucking_lcl"] * trucking_rate_count))
      expect(result_frame["range_unit"].to_a).to eq(["shipment"] + (["kg"] * trucking.rates["kg"].count) + (["cbm"] * trucking.rates["cbm"].count))
    end
  end
end
