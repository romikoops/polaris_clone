# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Coordinators::Truckings::Base do
  include_context "with standard trucking setup"
  include_context "with trucking_sheet"

  before do
    Organizations.current_id = organization.id
  end

  let(:coordinator) { described_class.new(state: parent_arguments) }

  context "instance methods" do
    describe ".combinator" do
      it "raises a Not Implemented error" do
        expect { coordinator.combinator }.to raise_error(NotImplementedError)
      end
    end

    describe ".restructurer" do
      it "raises a Not Implemented error" do
        expect { coordinator.restructurer }.to raise_error(NotImplementedError)
      end
    end
  end
end
