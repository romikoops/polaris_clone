# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::PipelineExecutor do
  include_context "V3 setup"
  let(:state_arguments) do
    ExcelDataServices::V3::State.new(
      file: file,
      section: section_string,
      overrides: overrides
    )
  end
  let(:section_parser) { instance_double(ExcelDataServices::V3::Files::SectionParser, global_actions: global_actions, connected_actions: connected_actions) }
  let(:service) { described_class.new(state: state_arguments, section_parser: section_parser) }
  let(:global_actions) { [instance_double(ExcelDataServices::V3::Files::RowValidation, state: state_arguments)] }
  let(:connected_actions) { [connected_action] }
  let(:connected_action) { instance_double("ConnectedActions", actions: [extractor_double]) }
  let(:extractor_double) { instance_double(ExcelDataServices::V3::Extractors::Carrier, state: state_arguments) }
  let(:global_action_executor_double) { instance_double(ExcelDataServices::V3::Files::ActionExecutor, perform: state_arguments) }
  let(:connected_action_executor_double) { instance_double(ExcelDataServices::V3::Files::ActionExecutor, perform: state_arguments) }

  before do
    allow(ExcelDataServices::V3::Files::ActionExecutor).to receive(:new).with(state: state_arguments, actions: global_actions).and_return(global_action_executor_double)
    allow(ExcelDataServices::V3::Files::ActionExecutor).to receive(:new).with(state: state_arguments, actions: [extractor_double]).and_return(connected_action_executor_double)
  end

  describe "#perform" do
    context "when there is only one ConnectedAction" do
      before { service.perform }

      it "triggers the ActionExecutor", :aggregate_failures do
        expect(global_action_executor_double).to have_received(:perform).once
        expect(connected_action_executor_double).to have_received(:perform).once
      end
    end

    context "when there are errors in the connected actions" do
      let(:connected_action_errors) { ["x"] }
      let(:connected_action_executor_double) { instance_double(ExcelDataServices::V3::Files::ActionExecutor, perform: state_arguments.dup.tap { |tapped_state| tapped_state.errors = connected_action_errors }) }

      context "when there is are multiple ConnectedActions and the first one fails" do
        let(:connected_actions) { [connected_action, second_action_double] }
        let(:second_action_double) { instance_double("ConnectedAction", actions: []) }

        before { service.perform }

        it "will not trigger the importer or the second ConnectedAction", :aggregate_failures do
          expect(connected_action_executor_double).to have_received(:perform).once
          expect(second_action_double).not_to have_received(:actions)
        end
      end

      context "when there are errors in performing the Actions" do
        it "triggers the ActionExecutor", :aggregate_failures do
          expect(service.perform.errors).to eq(connected_action_errors)
          expect(connected_action_executor_double).to have_received(:perform).once
        end
      end
    end

    context "when there are errors in the global actions" do
      let(:global_action_errors) { ["x"] }
      let(:global_action_executor_double) { instance_double(ExcelDataServices::V3::Files::ActionExecutor, perform: state_arguments.tap { |tapped_state| tapped_state.errors = global_action_errors }) }

      it "triggers the ActionExecutor", :aggregate_failures do
        expect(service.perform.errors).to eq(global_action_errors)
        expect(global_action_executor_double).to have_received(:perform).once
        expect(connected_action_executor_double).not_to have_received(:perform)
      end
    end
  end
end
