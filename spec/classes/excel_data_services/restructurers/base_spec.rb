# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Restructurers::Base do
  let(:tenant) { create(:tenant) }
  let(:options) { { tenant: tenant, data: data } }

  describe '.restructure' do
    let(:data) { { some_data: 123 } }

    it 'passes the data on without restructuring' do
      expect(described_class.restructure(options)).to eq('Unknown' => data)
    end
  end
end
