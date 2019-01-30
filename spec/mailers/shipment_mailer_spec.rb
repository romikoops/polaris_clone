# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:shipment) { create(:shipment, user: user, with_breakdown: true) }

  describe 'tenant_notification' do
    let(:mail) { described_class.tenant_notification(user, shipment).deliver_now }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Your booking through Demo')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'shipper_notification' do
    let(:mail) { described_class.shipper_notification(user, shipment).deliver_now }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Your booking through Demo')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@demo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'shipper_confirmation' do
    let(:mail) { described_class.shipper_confirmation(user, shipment).deliver_now }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Your booking through Demo')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@demo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.email])
    end
  end
end
