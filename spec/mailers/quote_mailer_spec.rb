# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteMailer, type: :mailer do
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { create(:user, tenant: tenant, with_profile: true) }
  let(:original_shipment) do
    create(:legacy_shipment,
      :with_meta,
      user: user,
      tenant: tenant,
      with_breakdown: true,
      with_tenders: true).tap do |shipment|
      shipment.trip_id = nil
    end
  end
  let(:shipment_count) { 1 }
  let(:quotation) do
    create(:legacy_quotation, user: user, shipment_count: shipment_count).tap do |quotation|
      quotation.original_shipment_id = original_shipment.id
    end
  end

  before do
    stub_request(:get,
      'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200,
                                                                                  body: '',
                                                                                  headers: {})
    stub_request(:get,
      'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200,
                                                                           body: '',
                                                                           headers: {})
    stub_request(:post,
      "#{Settings.breezy.url}/render/html").to_return(status: 201,
                                                      body: '',
                                                      headers: {})
    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
  end

  describe 'quotation_email' do
    let(:mail) { described_class.quotation_email(original_shipment, quotation.shipments, user.email, quotation, false).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference}"
      )
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'quotation_admin_ email for quotation' do
    let(:shipment_count) { 2 }
    let(:mail) { described_class.quotation_admin_email(quotation).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference},..."
      )
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_ email for shipment' do
    let(:mail) { described_class.quotation_admin_email(nil, original_shipment).deliver_now }
    let(:pickup_address) { FactoryBot.create(:gothenburg_address) }
    let(:delivery_address) { FactoryBot.create(:hamburg_address) }

    before do
      allow(original_shipment).to receive(:has_pre_carriage?).and_return(true)
      allow(original_shipment).to receive(:has_on_carriage?).and_return(true)
      allow(original_shipment).to receive(:pickup_address).and_return(pickup_address)
      allow(original_shipment).to receive(:delivery_address).and_return(delivery_address)
    end
    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Quotation: #{pickup_address.city} - #{delivery_address.city}, Refs: #{original_shipment.imc_reference}")
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end
end
