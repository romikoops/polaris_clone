# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Hub, type: :model do
    let(:hub) { FactoryBot.build(:legacy_hub) }
    describe '.point_wkt' do
      it 'returns the Rgeo WKT point of the hub' do
        expect(hub.point_wkt).to eq( "Point (#{hub.address.longitude} #{hub.address.latitude})")
      end
    end
  end
end
