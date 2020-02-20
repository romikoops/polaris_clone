# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::Notes do
  let(:tenant) { create(:tenant) }
  let(:target) { create(:country) }

  describe '.perform' do
    it 'finds a note record with the same header and tenant and updates it with new data' do
      create(:legacy_note, target: target, header: target.name, tenant: tenant)
      result = described_class.new(tenant: tenant, data: [country: target.code, note: 'hi', contains_html: true], options: {}).perform
      expect(result[:notes][:number_created]).to eq(0)
    end

    it 'finds a note record with the same header and updates it with new data' do
      tenant_two = create(:tenant)
      create(:legacy_note, target: target, header: target.name, tenant: tenant_two)
      result = described_class.new(tenant: tenant, data: [country: target.code, note: 'hi', contains_html: true], options: {}).perform
      expect(result[:notes][:number_created]).to eq(1)
    end

    it 'creates a new record when it does not find a record with the same header' do
      result = described_class.new(tenant: tenant, data: [country: target.code], options: {}).perform
      expect(result[:notes][:number_created]).to eq(1)
    end
  end
end
