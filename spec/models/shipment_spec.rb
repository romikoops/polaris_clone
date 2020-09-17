# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shipment, type: :model do
  before do
    create(:charge_breakdown,
           shipment: shipment,
           trip: other_trip,
           valid_until: 10.days.from_now.beginning_of_day,
           charge_category_name: 'Cargo1')
  end

  let(:itinerary) { create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:organization) { create(:organizations_organization) }
  let(:shipment) { create(:shipment, organization: organization, with_breakdown: true) }
  let(:other_trip) { create(:trip) }
  let(:hidden_value_service) { instance_double(Pdf::HiddenValueService) }

  before do
    FactoryBot.create(:profiles_profile,
                      first_name: 'Test',
                      last_name: 'User',
                      company_name: 'ItsMyCargo',
                      user_id: shipment.user_id)
  end

  context 'when hidden grand totals is true' do
    before do
      allow(Pdf::HiddenValueService).to receive(:new).and_return(hidden_value_service)
      allow(hidden_value_service).to receive(:hide_total_args).and_return(hidden_grand_total: false)
    end

    describe '.valid_until' do
      it 'returns the Charge Breakdown valid_until value for the shipment trip' do
        expect(shipment.valid_until(shipment.trip)).to eq(4.days.from_now.beginning_of_day)
      end

      it 'returns the Charge Breakdown valid_until value a different trip' do
        expect(shipment.valid_until(other_trip)).to eq(10.days.from_now.beginning_of_day)
      end
    end
  end

  context 'when searching via user profiles' do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let!(:shipment) { FactoryBot.create(:shipment, organization: organization, user: user) }

    context 'when searching via user names' do
      it 'returns shipments matching with users matching the name provided' do
        expect(described_class.user_name('Test')).to include(shipment)
      end
    end

    context 'when searching via company names' do
      it 'returns shipments matching with users matching the company name provided' do
        expect(described_class.company_name('ItsMyCargo')).to include(shipment)
      end
    end
  end
end

# == Schema Information
#
# Table name: shipments
#
#  id                                  :bigint           not null, primary key
#  booking_placed_at                   :datetime
#  cargo_notes                         :string
#  closing_date                        :datetime
#  customs                             :jsonb
#  customs_credit                      :boolean          default(FALSE)
#  deleted_at                          :datetime
#  desired_start_date                  :datetime
#  direction                           :string
#  eori                                :string
#  has_on_carriage                     :boolean
#  has_pre_carriage                    :boolean
#  imc_reference                       :string
#  incoterm_text                       :string
#  insurance                           :jsonb
#  load_type                           :string
#  meta                                :jsonb
#  notes                               :string
#  planned_delivery_date               :datetime
#  planned_destination_collection_date :datetime
#  planned_eta                         :datetime
#  planned_etd                         :datetime
#  planned_origin_drop_off_date        :datetime
#  planned_pickup_date                 :datetime
#  status                              :string
#  total_goods_value                   :jsonb
#  trucking                            :jsonb
#  uuid                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  destination_hub_id                  :integer
#  destination_nexus_id                :integer
#  distinct_id                         :uuid
#  incoterm_id                         :integer
#  itinerary_id                        :integer
#  old_user_id                         :integer
#  organization_id                     :uuid
#  origin_hub_id                       :integer
#  origin_nexus_id                     :integer
#  quotation_id                        :integer
#  sandbox_id                          :uuid
#  tenant_id                           :integer
#  tender_id                           :uuid
#  trip_id                             :integer
#  user_id                             :uuid
#
# Indexes
#
#  index_shipments_on_organization_id  (organization_id)
#  index_shipments_on_sandbox_id       (sandbox_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tenant_id        (tenant_id) WHERE (deleted_at IS NULL)
#  index_shipments_on_tender_id        (tender_id)
#  index_shipments_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (transport_category_id => transport_categories_20200504.id)
#
