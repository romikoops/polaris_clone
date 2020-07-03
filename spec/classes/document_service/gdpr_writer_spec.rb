# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentService::GdprWriter do
  context '.perform' do
    subject { described_class.new(user_id: user.id) }
    subject(:writer) { described_class.new(user_id: user.id) }

    let(:user) { create(:organizations_user) }
    let!(:contact) { create(:legacy_contact, user: user) }
    let!(:shipment) { create(:complete_legacy_shipment, user: user, with_breakdown: true, with_tenders: true) }

    before do
      create(:profiles_profile,
             first_name: 'Max',
             last_name: 'Muster',
             user_id: user.id)
    end

    it 'creates file' do
      expect(subject).to receive(:write_to_aws).with('tmp/Max_Muster_GDPR.xlsx', user.organization, 'Max_Muster_GDPR.xlsx', 'gdpr').and_return('http://AWS')

      expect(subject.perform).to eq('http://AWS')
    end

    it 'creates file in db' do
      aggregate_failures do
        expect(writer.perform).to include('Max_Muster_GDPR.xlsx')
        expect(Legacy::File.count).to eq(1)
      end
    end
  end
end
