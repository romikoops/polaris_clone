# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe DashboardService, type: :service do
    let(:quote_tenant) { FactoryBot.create(:legacy_tenant, name: 'Demo1', subdomain: 'demo1') }
    let(:quote_user_legacy) { FactoryBot.create(:legacy_user, tenant: quote_tenant, email: 't@example.com') }
    let(:quote_user) { Tenants::User.find_by(legacy_id: quote_user_legacy.id) }
    let(:start_date) { DateTime.new(2020, 2, 10) }
    let(:end_date) { DateTime.new(2020, 3, 10) }

    describe 'with activeClientCount widget' do
      let(:widget_class) { Analytics::Dashboard::ActiveClientCount }
      let(:widget) { widget_class.new(user: quote_user, start_date: start_date, end_date: end_date) }
      let(:mock_result) { 1 }

      before do
        allow(widget_class).to receive(:new).and_return(widget)
        allow(widget).to receive(:data).and_return(mock_result)
      end

      it 'instantiates the correct widget class and calls the service' do
        result = described_class.data(user: quote_user,
                                      widget_name: 'activeClientCount',
                                      start_date: start_date,
                                      end_date: end_date)

        expect(result).to eq(mock_result)
      end
    end
  end
end
