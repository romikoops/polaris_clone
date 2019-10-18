# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentService::GdprWriter do
  context '.perform' do
    subject { described_class.new(user_id: user.id) }

    let(:user) { create(:user, first_name: 'Max', last_name: 'Muster') }
    let!(:contact) { create(:contact, user: user) }
    let!(:shipment) { create(:shipment, user: user, with_breakdown: true) }

    it 'creates file' do
      expect(subject).to receive(:write_to_aws).with('tmp/Max_Muster_GDPR.xlsx', Legacy::Tenant.find(user.tenant_id), 'Max_Muster_GDPR.xlsx', 'gdpr').and_return('http://AWS')

      expect(subject.perform).to eq('http://AWS')
    end
  end
end
