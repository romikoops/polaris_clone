# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loader::Base do
  let(:tenant) { create(:tenant) }
  let(:base_loader) do
    described_class.new(
      tenant: tenant,
      specific_identifier: specific_identifier
    )
  end

  describe '#perform' do
    %w(OceanLcl LocalCharges ChargeCategories).each do |specific_identifier|
      context "with #{specific_identifier}" do
        let(:specific_identifier) { specific_identifier }
        it 'raises a NotImplementedError' do
          expect { base_loader.perform }.to raise_error(NotImplementedError,
                                                        "This method must be implemented in #{described_class.name}.")
        end
      end
    end
  end
end
