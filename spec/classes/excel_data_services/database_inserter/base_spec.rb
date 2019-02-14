# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserter::Base do
  let(:tenant) { create(:tenant) }
  let(:data) {}
  let(:klass_identifier) {}
  let(:options) { { tenant: tenant, data: data, klass_identifier: klass_identifier, options: {} } }

  describe '.insert' do
    it 'raises a NotImplementedError' do
      expect { described_class.insert(options) }.to raise_error(NotImplementedError)
    end
  end
end
