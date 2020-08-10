# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::WidgetSerializer do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:widget) { FactoryBot.create(:cms_data_widget, organization: organization, data: "Test widget data") }
    let(:serialized_widget) { described_class.new(widget).serializable_hash }

    it "returns the correct data for the object passed" do
      expect(serialized_widget.dig(:data, :attributes, :data)).to eq("Test widget data")
    end
  end
end
