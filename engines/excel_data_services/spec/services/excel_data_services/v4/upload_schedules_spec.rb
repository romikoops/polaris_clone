# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:xlsx) { File.open(file_fixture("excel/example_schedules.xlsx")) }

  before do
    %w[EUR USD].each do |currency|
      FactoryBot.create(:treasury_exchange_rate, to: currency)
    end
  end

  describe "#perform" do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Hamburg Sud", code: "hamburg sud") }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization) }
    let(:origin_hub) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
    let(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
    let(:result_stats) { service.perform }
    let(:schedule_count) { Schedules::Schedule.all.count }

    shared_examples_for "schedule creation fails" do
      it "no schedules are created" do
        expect(schedule_count).to eq 0
      end

      it "the result state contains valid error" do
        expect(result_stats[:errors].map(&:reason)).to include(error_reason)
      end
    end

    before do
      carrier
      tenant_vehicle
      origin_hub
      destination_hub
      result_stats
    end

    context "with valid data" do
      it "creates 2 schedules" do
        expect(schedule_count).to eq 2
      end
    end

    context "with incorrect hub" do
      let(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, organization: organization) }
      let(:error_reason) { "The origin hub 'DEHAM' cannot be found. Please check that the information is entered correctly" }

      it_behaves_like "schedule creation fails"
    end

    context "with incorrect carrier" do
      let(:carrier) { FactoryBot.create(:legacy_carrier, name: "MSC", code: "msc") }
      let(:error_reason) { "The Carrier 'Hamburg Sud' cannot be found." }

      it_behaves_like "schedule creation fails"
    end

    context "with incorrect tenant vehicle" do
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "cheapest", carrier: carrier, organization: organization) }
      let(:error_reason) { "The service 'standard (Hamburg Sud)' cannot be found." }

      it_behaves_like "schedule creation fails"
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an schedules sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_schedules.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
