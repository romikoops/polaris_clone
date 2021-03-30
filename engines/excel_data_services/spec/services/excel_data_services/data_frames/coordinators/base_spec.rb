# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Coordinators::Base do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
  end

  let(:coordinator) { described_class.new(state: parent_arguments) }

  context "instance methods" do
    describe ".combinator_state" do
      it "raises a Not Implemented error" do
        expect { coordinator.combinator_state }.to raise_error(NotImplementedError)
      end
    end

    describe ".restructured_data" do
      it "raises a Not Implemented error" do
        expect { coordinator.restructured_data }.to raise_error(NotImplementedError)
      end
    end
  end
end
