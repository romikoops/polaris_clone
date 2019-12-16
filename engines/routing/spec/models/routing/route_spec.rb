# frozen_string_literal: true

require 'rails_helper'

module Routing
  RSpec.describe Route, type: :model do
    describe 'validity' do
      it 'creates a valid object' do
        route = FactoryBot.create(:freight_route)
        expect(route).to be_valid
      end
    end

    describe 'carriage?' do
      let(:carriage_route) { FactoryBot.build(:routing_route, mode_of_transport: :carriage) }
      let(:ocean_route) { FactoryBot.build(:routing_route, mode_of_transport: :ocean) }

      it 'returns true if mode of transport is carriage' do
        expect(carriage_route.carriage?).to be true
      end

      it 'returns false if mode of transport is not carriage' do
        expect(ocean_route.carriage?).to be false
      end
    end
  end
end
