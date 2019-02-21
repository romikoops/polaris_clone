# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DocumentService::GdprWriter do
  context '.perform' do
    let(:user) { create(:user, first_name: 'Max', last_name: 'Muster') }
    let!(:contact) { create(:contact, user: user) }
    let!(:shipment) { create(:shipment, user: user, with_breakdown: true) }

    subject { described_class.new(user_id: user.id) }

    it 'creates file' do
      expect(subject).to receive(:write_to_aws).with('tmp/Max_Muster_GDPR.xlsx', user.tenant, 'Max_Muster_GDPR.xlsx', 'gdpr').and_return('http://AWS')

      expect(subject.perform).to eq('http://AWS')
    end
  end
end
