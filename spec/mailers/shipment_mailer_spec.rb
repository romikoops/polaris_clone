# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentMailer, type: :mailer do
  let(:user) { create(:legacy_user) }
  let(:tenant) { user.tenant }
  let!(:shipment) {
    create(:complete_legacy_shipment,
      user: user,
      tenant: user.tenant,
      with_breakdown: true,
      with_tenders: true)
  }
  let(:profile) { FactoryBot.build(:profiles_profile) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, "#{Settings.breezy.url}/render/html").to_return(status: 201, body: '', headers: {})
    allow(Profiles::ProfileService).to receive(:fetch).and_return(Profiles::ProfileDecorator.new(profile))
    %w[EUR USD].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=#{currency}")
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})
    end

    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
  end

  describe 'tenant_notification' do
    let(:mail) { described_class.tenant_notification(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'shipper_notification' do
    let(:mail) { described_class.shipper_notification(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'shipper_confirmation' do
    let(:mail) { described_class.shipper_confirmation(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end
end
