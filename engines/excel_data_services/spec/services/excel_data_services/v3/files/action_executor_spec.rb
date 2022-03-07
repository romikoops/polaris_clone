# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::ActionExecutor do
  include_context "V3 setup"
  let(:state_arguments) do
    ExcelDataServices::V3::State.new(
      file: file,
      section: section_string,
      overrides: overrides
    )
  end
  let(:service) { described_class.new(state: state_arguments, actions: [action_double]) }
  let(:action_double) { class_double(ExcelDataServices::V3::Formatters::Pricing) }

  describe "#perform" do
    before do
      allow(action_double).to receive(:state).with(state: state_arguments).and_return(state_arguments)
    end

    context "when there are no errors" do
      context "when there is only one Action" do
        it "triggers the action in the array", :aggregate_failures do
          expect(service.perform).to eq(state_arguments)
          expect(action_double).to have_received(:state).once
        end
      end

      context "when there are two Actions" do
        let(:second_action_double) { class_double(ExcelDataServices::V3::Formatters::Pricing) }
        let(:service) { described_class.new(state: state_arguments, actions: [action_double, second_action_double]) }

        before do
          allow(second_action_double).to receive(:state).with(state: state_arguments).and_return(state_arguments)
        end

        it "triggers boths actions in the array", :aggregate_failures do
          expect(service.perform).to eq(state_arguments)
          expect(action_double).to have_received(:state).once
          expect(second_action_double).to have_received(:state).once
        end
      end
    end

    context "when there are errors" do
      before do
        allow(action_double).to receive(:state).with(state: state_arguments).and_return(state_arguments.dup.tap { |tapped_state| tapped_state.errors = ["x"] })
      end

      context "when there are two Actions and the first returns an error" do
        let(:second_action_double) { class_double(ExcelDataServices::V3::Formatters::LocalCharge) }
        let(:service) { described_class.new(state: state_arguments, actions: [action_double, second_action_double]) }

        before do
          allow(second_action_double).to receive(:state).with(state: state_arguments).and_return(state_arguments)
          service.perform
        end

        it "triggers only the first action", :aggregate_failures do
          expect(action_double).to have_received(:state).once
          expect(second_action_double).not_to have_received(:state)
        end
      end

      context "when there are errors in the State" do
        let(:state_arguments) do
          ExcelDataServices::V3::State.new(
            file: file,
            section: section_string,
            overrides: overrides
          ).tap { |tapped_state| tapped_state.errors = ["x"] }
        end

        before { service.perform }

        it "does not run any actions if errors are present" do
          expect(action_double).not_to have_received(:state)
        end
      end
    end
  end
end
