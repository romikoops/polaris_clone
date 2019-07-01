# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:shipment) { create(:shipment, user: user, with_breakdown: true) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, 'https://breezypdf.itsmycargo.tech/render/html').to_return(status: 201, body: '', headers: {})
  end

  describe 'tenant_notification' do
    let(:mail) { described_class.tenant_notification(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq('Your booking through Demo')
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'shipper_notification' do
    let(:mail) { described_class.shipper_notification(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq('Your booking through Demo')
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'shipper_confirmation' do
    let(:mail) { described_class.shipper_confirmation(user, shipment, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq('Your booking through Demo')
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end
end
