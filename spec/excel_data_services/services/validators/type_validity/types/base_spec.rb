# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::TypeValidity::Types::Base do
  describe ".valid?" do
    it "raises a NotImplementedError" do
      expect { described_class.new(nil).valid? }.to raise_error(NotImplementedError)
    end
  end
end
