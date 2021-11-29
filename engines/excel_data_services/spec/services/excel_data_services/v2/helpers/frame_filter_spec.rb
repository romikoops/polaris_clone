# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Helpers::FrameFilter do
  let(:input_frame) { Rover::DataFrame.new(input_data) }
  let(:input_data) do
    [
      { a: 1, b: 2, c: 3 },
      { a: 4, b: 5, c: 6 },
      { a: 2, b: 3, c: 6 }
    ]
  end

  describe "#frame" do
    let(:result_frame) { described_class.new(input_frame: input_frame, arguments: input_frame.first).frame }

    it "returns only the first row of the frame" do
      expect(result_frame).to eq(Rover::DataFrame.new([input_data[0]]))
    end
  end
end
