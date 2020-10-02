# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Tender, type: :model do
    subject { FactoryBot.build :quotations_tender }

    context 'Associations' do
      %i(quotation origin_hub destination_hub tenant_vehicle line_items).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end

    context 'with multiple tenders' do
      before do
        Timecop.freeze(Time.zone.parse('01/10/2020')) do
          FactoryBot.create_list(:quotations_tender, 2)
        end
      end

      let(:quotations_tender) { Quotations::Tender.order(:created_at) }

      it 'matches reference numbers to dates', :aggregate_failures do
        expect(quotations_tender.pluck(:imc_reference).first[0..3]).to eq('0110')
        expect(quotations_tender.pluck(:imc_reference).last[0..3]).to eq('0110')
        expect(quotations_tender.pluck(:imc_reference).first[5..11]).to eq('2000001')
        expect(quotations_tender.pluck(:imc_reference).last[5..11]).to eq('2000002')
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations_tenders
#
#  id                         :uuid             not null, primary key
#  amount_cents               :integer
#  amount_currency            :string
#  carrier_name               :string
#  load_type                  :string
#  name                       :string
#  original_amount_cents      :integer
#  original_amount_currency   :string
#  transshipment              :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  delivery_tenant_vehicle_id :integer
#  destination_hub_id         :integer
#  itinerary_id               :integer
#  origin_hub_id              :integer
#  pickup_tenant_vehicle_id   :integer
#  quotation_id               :uuid
#  tenant_vehicle_id          :bigint
#
# Indexes
#
#  index_quotations_tenders_on_delivery_tenant_vehicle_id  (delivery_tenant_vehicle_id)
#  index_quotations_tenders_on_destination_hub_id          (destination_hub_id)
#  index_quotations_tenders_on_origin_hub_id               (origin_hub_id)
#  index_quotations_tenders_on_pickup_tenant_vehicle_id    (pickup_tenant_vehicle_id)
#  index_quotations_tenders_on_quotation_id                (quotation_id)
#  index_quotations_tenders_on_tenant_vehicle_id           (tenant_vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (delivery_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (pickup_tenant_vehicle_id => tenant_vehicles.id)
#  fk_rails_...  (quotation_id => quotations_quotations.id)
#
