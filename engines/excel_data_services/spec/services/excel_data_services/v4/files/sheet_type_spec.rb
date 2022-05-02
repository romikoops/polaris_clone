# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::SheetType do
  include_context "V4 setup"
  let(:service) { described_class.new(type: "Pricings", file: file, arguments: arguments) }
  let(:arguments) { {} }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    it "returns true when the sheet is pricings sheet" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#perform (unit)" do
    let(:pipeline) { instance_double("ExcelDataServices::V4::Files::Section", perform: dummy_state) }
    let(:pipelines) { [pipeline] }
    let(:dummy_state) { instance_double("ExcelDataServices::V4::State", errors: [], stats: [{}]) }

    before do
      allow(service).to receive(:pipelines).and_return(pipelines)
    end

    context "when no errors occur on a single pipeline" do
      it "triggers the pipelines and returns the State object", :aggregate_failures do
        expect(service.perform).to be_a(ExcelDataServices::V4::State)
        expect(pipeline).to have_received(:perform)
        expect(dummy_state).to have_received(:errors)
        expect(dummy_state).to have_received(:stats)
      end
    end

    context "when an error occur on a single pipeline" do
      let(:error_state) { instance_double("ExcelDataServices::V4::State", errors: ["There was an error"], stats: [{}]) }
      let(:error_pipeline) { instance_double("ExcelDataServices::V4::Files::Section", perform: error_state) }
      let(:pipelines) { [error_pipeline, pipeline] }

      it "triggers the pipelines and returns the State object", :aggregate_failures do
        expect(service.perform).to be_a(ExcelDataServices::V4::State)
        expect(pipeline).not_to have_received(:perform)
      end
    end
  end

  describe "#state" do
    let(:arguments) { { group_id: SecureRandom.uuid } }
    let(:state) { service.state }

    it "returns a V4::State object with the correct Overrides defined", :aggregate_failures do
      expect(state).to be_a(ExcelDataServices::V4::State)
      expect(state.overrides.group_id).to eq(arguments[:group_id])
    end
  end
end
