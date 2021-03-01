# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ResultSerializer do
    let(:result) { FactoryBot.create(:journey_result) }
    let(:decorated_result) { Api::V1::ResultDecorator.new(result) }
    let(:serialized_result) { described_class.new(decorated_result).serializable_hash }
    let(:target) { serialized_result.dig(:data, :attributes) }

    it "returns the correct modes of transport for the object passed" do
      expect(target[:modesOfTransport]).to eq(["ocean"])
    end
  end
end
