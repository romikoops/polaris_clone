# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QuerySerializer do
    include_context "journey_pdf_setup"
    let(:address) { FactoryBot.create(:legacy_address) }
    let(:nexus) { FactoryBot.create(:legacy_nexus) }
    let(:decorated_query) { Api::V1::QueryDecorator.new(query) }
    let(:serialized_query) { described_class.new(decorated_query).serializable_hash }
    let(:target) { serialized_query.dig(:data, :attributes) }

    it "returns the correct selected_date for the object passed" do
      expect(target[:selectedDate]).to eq(query.cargo_ready_date)
    end

    it "returns the correct user for the object passed" do
      expect(target[:user]).to be_a(Api::V1::UserSerializer)
    end

    it "returns the correct creator for the object passed" do
      expect(target[:creator]).to be_a(Api::V1::UserSerializer)
    end
  end
end
