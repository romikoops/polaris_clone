# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:data) {}
  let(:options) { {} }
  let(:arguments) { {organization: organization, data: data, options: options} }

  describe ".get" do
    it "finds the correct child class" do
      expect(described_class.get("Pricing")).to eq(ExcelDataServices::Inserters::Pricing)
    end
  end

  describe ".insert" do
    it "raises a NotImplementedError" do
      expect { described_class.insert(arguments) }.to raise_error(NotImplementedError)
    end
  end

  describe ".find_group_id" do
    let(:row_data) do
      {
        group_id: group_id,
        group_name: group_name
      }
    end
    let(:group_name) { "Test Group" }
    let(:group_id) { group.id }
    let(:row) { ExcelDataServices::Rows::Pricing.new(row_data: row_data, organization: organization) }
    let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
    let!(:default_group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
    let(:result_id) { described_class.new(arguments).send(:find_group_id, row) }

    context "when group_id is on the row" do
      it "returns the correct group id" do
        expect(result_id).to eq(group_id)
      end
    end

    context "when group_name is on the row" do
      let(:group_id) { nil }

      it "returns the correct group id" do
        expect(result_id).to eq(group.id)
      end
    end

    context "when no group_id or group name is on the row" do
      let(:group_id) { nil }
      let(:group_name) { nil }

      it "returns the deafult group id" do
        expect(result_id).to eq(default_group.id)
      end
    end

    context "when group_id is in the options" do
      let(:options) { {group_id: group.id} }
      let(:group_name) { nil }
      let(:group_id) { nil }

      it "returns the correct group id" do
        expect(result_id).to eq(group.id)
      end
    end
  end
end
