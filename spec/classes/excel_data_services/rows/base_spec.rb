# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Rows::Base do
  let(:tenant) { create(:tenant) }
  let(:row) { described_class.new(tenant: tenant, row_data: { row_nr: 1 }) }

  describe '#[]' do
    it 'finds the corresponding \'.\' method (row[:nr] --> row.nr)' do
      expect(row[:nr]).to eq(1)
    end
  end
end
