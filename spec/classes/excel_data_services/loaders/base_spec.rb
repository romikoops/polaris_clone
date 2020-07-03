# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Loaders::Base do
  let(:organization) { create(:organizations_organization) }
  let(:base_loader) { described_class.new(organization: organization) }

  describe '#perform' do
    it 'raises a NotImplementedError' do
      expect { base_loader.perform }.to raise_error(NotImplementedError,
                                                    "This method must be implemented in #{described_class.name}.")
    end
  end
end
