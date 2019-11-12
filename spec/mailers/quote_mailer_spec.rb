# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteMailer, type: :mailer do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  let(:original_shipment) do
    create(:shipment, user: user, tenant: tenant, with_breakdown: true).tap do |shipment|
      shipment.trip_id = nil
    end
  end
  let(:quotation) do
    create(:quotation, user: user, shipment_count: 1).tap do |quotation|
      quotation.original_shipment_id = original_shipment.id
    end
  end

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, "#{Settings.breezy.url}/render/html").to_return(status: 201, body: '', headers: {})
  end

  describe 'quotation_email' do
    let(:mail) { described_class.quotation_email(original_shipment, quotation.shipments, user.email, quotation, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("Quotation for #{quotation.shipments.pluck(:imc_reference).join(',')}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'quotation_admin_ email for quotation' do
    let(:mail) { described_class.quotation_admin_email(quotation).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("Quotation for #{quotation.shipments.pluck(:imc_reference).join(',')}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_ email for shipment' do
    let(:mail) { described_class.quotation_admin_email(nil, original_shipment).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("Quotation for #{original_shipment.imc_reference}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end
end
