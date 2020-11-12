# frozen_string_literal: true

require 'rails_helper'

module Quotations
  RSpec.describe Quotations::Quotation, type: :model do
    subject { FactoryBot.build :quotations_quotation }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user_one) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:user_two) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:itinerary_one) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
    let(:itinerary_two) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
    let(:origin_nexus_one) { itinerary_one.origin_hub.nexus }
    let(:destination_nexus_one) { itinerary_one.destination_hub.nexus }
    let(:origin_nexus_two) { itinerary_two.origin_hub.nexus }
    let(:destination_nexus_two) { itinerary_two.destination_hub.nexus }

    let(:asc_quotation) {
      FactoryBot.create(:quotations_quotation,
        :cargo_item,
        organization: organization,
        origin_nexus: origin_nexus_one,
        destination_nexus: destination_nexus_one,
        selected_date: 1.day.ago,
        user: user_one)
    }
    let(:desc_quotation) {
      FactoryBot.create(:quotations_quotation,
        :container,
        organization: organization,
        origin_nexus: origin_nexus_two,
        destination_nexus: destination_nexus_two,
        selected_date: DateTime.now,
        user: user_two)
    }
    let(:sorted_quotations) { described_class.sorted(sort_by: sort_key, direction: direction_key) }

    context 'Associations' do
      %i(organization user origin_nexus destination_nexus).each do |association|
        it { is_expected.to respond_to(association) }
      end
    end

    context 'Validity' do
      it { is_expected.to be_valid }
    end

    context 'sorted by load_type' do
      let(:sort_key) { 'load_type' }

      before do
        FactoryBot.create(:quotations_tender, quotation: asc_quotation, load_type: 'cargo_item', itinerary: itinerary_one)
        FactoryBot.create(:quotations_tender, quotation: desc_quotation, load_type: 'container', itinerary: itinerary_two)
      end

      context 'sorted by load_type asc' do
        let(:direction_key) { 'asc' }

        it 'sorts quotation load types in ascending direction' do
          expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
        end
      end

      context 'sorted by load_type desc' do
        let(:direction_key) { 'desc' }

        it 'sorts quotationload types in descending direction' do
          expect(sorted_quotations).to eq([desc_quotation, asc_quotation])
        end
      end
    end

    context 'sorted by user last name' do
      let(:sort_key) { 'last_name' }

      before do
        FactoryBot.create(:profiles_profile, user: user_one, last_name: '1')
        FactoryBot.create(:profiles_profile, user: user_two, last_name: '2')
      end

      context 'sorted by user last name asc' do
        let(:direction_key) { 'asc' }

        it 'sorts quotations by their users first name in ascending direction' do
          expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
        end
      end

      context 'sorted by user last name desc' do
        let(:direction_key) { 'desc' }

        it 'sorts quotations by their users first name in descending direction' do
          expect(sorted_quotations).to eq([desc_quotation, asc_quotation])
        end
      end
    end

    context 'origin' do
      let(:sort_key) { 'origin' }

      context 'sorted by origin asc' do
        let(:direction_key) { 'asc' }

        it 'sorts quotations by their origins in ascending direction' do
          expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
        end
      end

      context 'sorted by origin desc' do
        let(:direction_key) { 'desc' }

        it 'sorts quotations by their origin in descending direction' do
          expect(sorted_quotations).to eq([desc_quotation, asc_quotation])
        end
      end
    end

    context 'sort by destination' do
      let(:sort_key) { 'destination' }

      context 'sorted by destination asc' do
        let(:direction_key) { 'asc' }

        it 'sorts quotations by their destination in ascending direction' do
          # desc_quotation has gothenburg as destination, therefore is first
          expect(sorted_quotations).to eq([desc_quotation, asc_quotation])
        end
      end

      context 'sorted by destination desc' do
        let(:direction_key) { 'desc' }

        it 'sorts quotations by their destination in descending direction' do
          # asc_quotation in this case has gothenburg as destination therefore is first
          expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
        end
      end
    end

    context 'sort by selected_date' do
      let(:sort_key) { 'selected_date' }

      context 'sorted by selected_date asc' do
        let(:direction_key) { 'asc' }

        it 'sorts quotations by their selected date in ascending direction' do
          expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
        end
      end

      context 'sorted by selected_date desc' do
        let(:direction_key) { 'desc' }

        it 'sorts quotations by their selected date in descending direction' do
          expect(sorted_quotations).to eq([desc_quotation, asc_quotation])
        end
      end
    end

    context 'without matching sort_by scope' do
      let(:sort_key) { 'nonsense' }
      let(:direction_key) { 'desc' }

      it 'returns default direction' do
        expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
      end
    end

    context 'without proper direction scope' do
      let(:sort_key) { 'selected_date' }
      let(:direction_key) { nil }

      it 'returns default direction' do
        expect(sorted_quotations).to eq([asc_quotation, desc_quotation])
      end
    end
  end
end

# == Schema Information
#
# Table name: quotations_quotations
#
#  id                   :uuid             not null, primary key
#  completed            :boolean          default(FALSE)
#  selected_date        :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  delivery_address_id  :integer
#  destination_nexus_id :integer
#  old_user_id          :bigint
#  organization_id      :uuid
#  legacy_shipment_id   :integer
#  origin_nexus_id      :integer
#  pickup_address_id    :integer
#  sandbox_id           :bigint
#  shipment_id          :integer
#  tenant_id            :uuid
#  tenants_user_id      :uuid
#  user_id              :uuid
#
# Indexes
#
#  index_quotations_quotations_on_destination_nexus_id  (destination_nexus_id)
#  index_quotations_quotations_on_old_user_id           (old_user_id)
#  index_quotations_quotations_on_organization_id       (organization_id)
#  index_quotations_quotations_on_origin_nexus_id       (origin_nexus_id)
#  index_quotations_quotations_on_sandbox_id            (sandbox_id)
#  index_quotations_quotations_on_tenant_id             (tenant_id)
#  index_quotations_quotations_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_     (user_id => users_users.id)
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
