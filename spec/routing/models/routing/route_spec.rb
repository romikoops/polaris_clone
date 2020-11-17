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

# == Schema Information
#
# Table name: routing_routes
#
#  id                      :uuid             not null, primary key
#  allowed_cargo           :integer          default(0), not null
#  mode_of_transport       :integer          default(NULL), not null
#  price_factor            :decimal(, )
#  time_factor             :decimal(, )
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  destination_id          :uuid
#  destination_terminal_id :uuid
#  origin_id               :uuid
#  origin_terminal_id      :uuid
#
# Indexes
#
#  routing_routes_index  (origin_id,destination_id,origin_terminal_id,destination_terminal_id,mode_of_transport) UNIQUE
#
