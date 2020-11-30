# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::DateOverlapConflicts::Base do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:klass) { described_class.state(state: combinator_arguments) }

  describe ".conflict_keys" do
    it "raises a Not Implemented error" do
      expect { klass.conflict_keys }.to raise_error(NotImplementedError)
    end
  end
end
