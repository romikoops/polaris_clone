# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Excel::Inserter do
  context 'class methods' do
    let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng) }
    let(:args) { { hub_id: hub.id, params: {} } }
    before do
      allow_any_instance_of(described_class).to receive(:xlsx).and_return(
        double('Roo:Xlsx', sheets: ['SHeet1'])
      )
    end

    describe '.alphanumeric_range' do
      it 'returns the correct alphanumeric range' do
        data = { min: 'AB12', max: 'AB16', country: 'GB' }
        result = described_class.new(args).alphanumeric_range(data)
        expect(result.map { |r| r[:ident] }).to eq(%w(AB12 AB13 AB14 AB15 AB16))
        expect(result.map { |r| r[:country] }).to eq(%w(GB GB GB GB GB))
      end
    end
  end
end
