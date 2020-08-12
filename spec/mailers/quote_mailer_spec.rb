# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteMailer, type: :mailer do
  let(:organization) { create(:organizations_organization, slug: 'demo') }
  let(:user) { create(:organizations_user, organization: organization) }
  let!(:profile) { FactoryBot.create(:profiles_profile, user: user, external_id: '1234') }
  let(:load_type) { 'container' }
  let(:original_shipment) do
    create(:complete_legacy_shipment,
      :with_meta,
      user: user,
      load_type: load_type,
      organization: organization,
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
  let(:pickup_address) { FactoryBot.create(:gothenburg_address) }
  let(:umlaut_address) { FactoryBot.create(:dusseldorf_address) }
  let(:delivery_address) { FactoryBot.create(:hamburg_address) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe 'quotation_email' do
    let(:mail) {
      described_class.quotation_email(
        original_shipment,
        quotation.shipments,
        user.email,
        quotation,
        quotation.shipments.pluck(:trip_id)
      ).deliver_now
    }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference}"
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'quotation_email (internal)' do
    let(:quotation) do
      create(:legacy_quotation, user: user, shipment_count: 1, original_shipment: original_shipment, billing: :internal)
    end
    let(:mail) {
      described_class.quotation_email(
        original_shipment,
        quotation.shipments,
        user.email,
        quotation,
        quotation.shipments.pluck(:trip_id)
      ).deliver_now
    }
    let(:imc_reference) { quotation.shipments.pluck(:imc_reference).join(',') }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([Settings.emails.booking])
    end
  end

  describe 'quotation_admin_ email for quotation' do
    let(:shipment_count) { 2 }
    let(:mail) { described_class.quotation_admin_email(quotation).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference},..."
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_ email for quotation wihtout user' do
    let(:shipment_count) { 2 }
    let(:mail) { described_class.quotation_admin_email(quotation).deliver_now }

    before { allow(quotation).to receive(:user_id).and_return(nil) }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotation.shipments.first.imc_reference},..."
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_ email for shipment' do
    let(:mail) { described_class.quotation_admin_email(nil, original_shipment).deliver_now }

    before do
      allow(original_shipment).to receive(:has_pre_carriage?).and_return(true)
      allow(original_shipment).to receive(:has_on_carriage?).and_return(true)
      allow(original_shipment).to receive(:pickup_address).and_return(pickup_address)
      allow(original_shipment).to receive(:delivery_address).and_return(delivery_address)
    end

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Quotation: #{pickup_address.city} - #{delivery_address.city}, Refs: #{original_shipment.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_ email for shipment with liquid template' do
    let(:mail) { described_class.quotation_admin_email(nil, original_shipment).deliver_now }
    let(:load_type) { 'cargo_item' }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:decorated_shipment) { Legacy::ShipmentDecorator.new(original_shipment) }
    let(:liquid) {
      "{{imc_reference}}/[{{external_id}}]/{{origin}}/{{destination}}/{{total_weight}}/{{total_volume}}"
    }
    let(:result) {
      [
        original_shipment.imc_reference.to_s,
        "[#{profile.external_id}]",
        original_shipment.origin_nexus.locode.to_s,
        original_shipment.destination_nexus.locode.to_s,
        decorated_shipment.total_weight.to_s,
        decorated_shipment.total_volume.to_s
      ].join('/')
    }

    before do
      FactoryBot.create(:organizations_scope, target: organization, content: {email_subject_template: liquid})
    end

    context 'with escaping' do
      before do
        allow(original_shipment).to receive(:origin_nexus).and_return(origin_hub.nexus)
        allow(original_shipment).to receive(:destination_nexus).and_return(destination_hub.nexus)
      end

      let(:liquid) {
        [
          'ItsMyCargo Quotation Tool: {{imc_reference}} - from: \'{{origin_city}}\' "{{origin}}" - to:',
          '\'{{destination_city}}\' "{{destination}}" / {{total_weight}}kg / {{total_volume}}cbm'
        ].join(' ')
      }
      let(:result) {
        [
          "ItsMyCargo Quotation Tool: #{original_shipment.imc_reference} - from:",
          "'Gothenburg' \"SEGOT\" - to: 'Shanghai' \"CNS..."
        ].join(' ')
      }

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq(result)
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
        expect(mail.to).to eq(['sales.general@demo.com'])
      end
    end

    context 'without trucking' do
      before do
        allow(original_shipment).to receive(:origin_nexus).and_return(origin_hub.nexus)
        allow(original_shipment).to receive(:destination_nexus).and_return(destination_hub.nexus)
      end

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq(result)
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
        expect(mail.to).to eq(['sales.general@demo.com'])
      end
    end

    context 'with trucking' do
      before do
        allow(original_shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(original_shipment).to receive(:has_on_carriage?).and_return(true)
        allow(original_shipment).to receive(:pickup_address).and_return(pickup_address)
        allow(original_shipment).to receive(:delivery_address).and_return(delivery_address)
      end

      let(:result) {
        [
          original_shipment.imc_reference.to_s,
          "[#{profile.external_id}]",
          "#{pickup_address.country.code}-#{pickup_address.zip_code}",
          "#{delivery_address.country.code}-#{delivery_address.zip_code}",
          decorated_shipment.total_weight.to_s,
          decorated_shipment.total_volume.to_s
        ].join('/')
      }

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq(result)
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
        expect(mail.to).to eq(['sales.general@demo.com'])
      end
    end

    context 'with trucking with umlaut' do
      before do
        allow(original_shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(original_shipment).to receive(:has_on_carriage?).and_return(true)
        allow(original_shipment).to receive(:pickup_address).and_return(umlaut_address)
        allow(original_shipment).to receive(:delivery_address).and_return(delivery_address)
      end

      let(:email_subject) do
        [
          original_shipment.imc_reference.to_s,
          "[#{profile.external_id}]",
          "#{umlaut_address.city} - #{delivery_address.city}",
          decorated_shipment.total_weight.to_s,
          decorated_shipment.total_volume.to_s
        ].join('/')
      end

      let(:liquid) do
        "{{imc_reference}}/[{{external_id}}]/{{routing}}/{{total_weight}}/{{total_volume}}"
      end

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq(email_subject)
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
        expect(mail.to).to eq(['sales.general@demo.com'])
      end
    end
  end
end
