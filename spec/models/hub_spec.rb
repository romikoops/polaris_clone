# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hub, type: :model do
  context 'instance methods' do
    context '.truck_type_availability' do
      TruckTypeAvailability.create_all!

      let(:hub) { create(:hub) }

      let(:truck_type_availabilities) do
        TruckTypeAvailability.where(
          load_type: 'cargo_item',
          truck_type: 'default'
        ).or(TruckTypeAvailability.where(
               load_type: 'container',
               truck_type: %w(chassis side_lifter),
               carriage: 'on'
             )).or(TruckTypeAvailability.where(
                     load_type: 'container',
                     truck_type: 'chassis',
                     carriage: 'pre'
                   ))
      end

      let!(:hub_truck_type_availabilities) do
        truck_type_availabilities.each do |truck_type_availability|
          create(:hub_truck_type_availability,
                 hub: hub, truck_type_availability: truck_type_availability)
        end
      end

      it 'returns a hash' do
        expect(hub.truck_type_availability).to be_a(Hash)
      end

      it 'returns the correct data' do
        expect(hub.truck_type_availability).to eq(
          'cargo_item' => {
            'pre' => %w(default),
            'on' => %w(default)
          },
          'container' => {
            'pre' => %w(chassis),
            'on' => %w(chassis side_lifter)
          }
        )
      end
    end
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry({:srid= geometry, 0
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  index_hubs_on_point       (point) USING gist
#  index_hubs_on_sandbox_id  (sandbox_id)
#  index_hubs_on_tenant_id   (tenant_id)
#
