# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Notes do
  let(:organization) { create(:organizations_organization) }
  let(:target) { create(:country) }

  describe '.perform' do
    it 'finds a note record with the same header and organization and updates it with new data' do
      create(:legacy_note, target: target, header: target.name, organization: organization)
      result = described_class.new(organization: organization, data: [country: target.code, note: 'hi', contains_html: true], options: {}).perform
      expect(result[:notes][:number_created]).to eq(0)
    end

    it 'finds a note record with the same header and updates it with new data' do
      organization_two = create(:organizations_organization)
      create(:legacy_note, target: target, header: target.name, organization: organization_two)
      result = described_class.new(organization: organization, data: [country: target.code, note: 'hi', contains_html: true], options: {}).perform
      expect(result[:notes][:number_created]).to eq(1)
    end

    it 'creates a new record when it does not find a record with the same header' do
      result = described_class.new(organization: organization, data: [country: target.code], options: {}).perform
      expect(result[:notes][:number_created]).to eq(1)
    end
  end
end
