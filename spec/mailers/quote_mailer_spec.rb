# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteMailer, type: :mailer do
  let(:organization) { create(:organizations_organization, slug: 'demo') }
  let(:user) { create(:organizations_user, organization: organization) }
  let!(:profile) { FactoryBot.create(:profiles_profile, user: user, external_id: '1234') }
  let(:load_type) { 'container' }
  let(:billing) { :external }
  let(:original_shipment) do
    create(:complete_legacy_shipment,
      :with_meta,
      user: user,
      billing: billing,
      load_type: load_type,
      organization: organization,
      with_breakdown: true,
      with_tenders: true).tap do |shipment|
      shipment.trip_id = nil
    end
  end
  let(:quotations_quotation) { Quotations::Quotation.find_by(legacy_shipment_id: original_shipment.id) }
  let(:shipment_count) { 1 }
  let(:quotation) do
    create(:legacy_quotation, user: user, original_shipment_id: original_shipment.id, shipment_count: shipment_count)
  end
  let(:pickup_address) { FactoryBot.create(:gothenburg_address) }
  let(:umlaut_address) { FactoryBot.create(:dusseldorf_address) }
  let(:delivery_address) { FactoryBot.create(:hamburg_address) }
  let(:cargo_total_weight) { "500.00" }
  let(:cargo_total_volume) { "1.34" }
  let(:emails) do
    {
      sales: {
        general: "sales.general@demo.com"
      },
      support: {
        general: "support@demo.com"
      }
    }
  end

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})
    original_shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, :with_email_logo, emails: emails, organization: organization)
  end

  describe 'quotation_email' do
    let(:mail) {
      described_class.new_quotation_email(
        quotation: quotations_quotation,
        tender_ids: quotations_quotation.tenders.ids,
        shipment: original_shipment,
        email: user.email
      ).deliver_now
    }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotations_quotation.tenders.first.imc_reference}"
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end

  describe 'quotation_email (internal)' do
    let(:billing) { :internal }
    let(:quotation) do
      create(:legacy_quotation, user: user, shipment_count: 1, original_shipment: original_shipment, billing: billing)
    end
    let(:mail) {
      described_class.new_quotation_email(
        quotation: quotations_quotation,
        tender_ids: quotations_quotation.tenders.ids,
        shipment: original_shipment,
        email: user.email
      ).deliver_now
    }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotations_quotation.tenders.first.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq(["itsmycargodev@gmail.com"])
    end
  end

  describe 'quotation_admin_ email for quotation' do
    let(:shipment_count) { 2 }
    let(:mail) { described_class.new_quotation_admin_email(quotation: quotations_quotation, shipment: original_shipment).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotations_quotation.tenders.first.imc_reference}"
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_email for quotation wihtout user' do
    let(:shipment_count) { 2 }
    let(:mail) { described_class.new_quotation_admin_email(quotation: quotations_quotation, shipment: original_shipment).deliver_now }

    before { allow(quotations_quotation).to receive(:user).and_return(nil) }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq(
        "FCL Quotation: Gothenburg - Gothenburg, Refs: #{quotations_quotation.tenders.first.imc_reference}"
      )
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_email for shipment' do
    let(:mail) { described_class.new_quotation_admin_email(quotation: quotations_quotation, shipment: original_shipment).deliver_now }

    before do
      allow(quotations_quotation).to receive(:pickup_address).and_return(pickup_address)
      allow(quotations_quotation).to receive(:delivery_address).and_return(delivery_address)
    end

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Quotation: #{pickup_address.city} - #{delivery_address.city}, Refs: #{quotations_quotation.tenders.first.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.tech'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end

  describe 'quotation_admin_email for misconfigured Organization' do
    let(:mail) { described_class.new_quotation_admin_email(quotation: quotations_quotation, shipment: original_shipment).deliver_now }
    let(:emails) { {sales: {general: ""}} }

    it 'corrects to the default email', :aggregate_failures do
      expect(mail.to).to eq(["itsmycargodev@gmail.com"])
    end
  end

  describe 'quotation_admin_ email for shipment with liquid template' do
    let(:mail) { described_class.new_quotation_admin_email(quotation: quotations_quotation, shipment: original_shipment).deliver_now }
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
        quotations_quotation.tenders.first.imc_reference,
        "[#{profile.external_id}]",
        quotations_quotation.origin_nexus.locode.to_s,
        quotations_quotation.destination_nexus.locode.to_s,
        cargo_total_weight,
        cargo_total_volume
      ].join('/')
    }

    before do
      FactoryBot.create(:organizations_scope, target: organization, content: {email_subject_template: liquid})
      original_shipment.update(imc_reference: quotations_quotation.tenders.first.imc_reference)
    end

    context 'with escaping' do
      before do
        allow(quotations_quotation).to receive(:origin_nexus).and_return(origin_hub.nexus)
        allow(quotations_quotation).to receive(:destination_nexus).and_return(destination_hub.nexus)
      end

      let(:liquid) {
        [
          'ItsMyCargo Quotation Tool: {{imc_reference}} - from: \'{{origin_city}}\' "{{origin}}" - to:',
          '\'{{destination_city}}\' "{{destination}}" / {{total_weight}}kg / {{total_volume}}cbm'
        ].join(' ')
      }
      let(:result) {
        [
          "ItsMyCargo Quotation Tool: #{quotations_quotation.tenders.first.imc_reference} - from:",
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
        allow(quotations_quotation).to receive(:origin_nexus).and_return(origin_hub.nexus)
        allow(quotations_quotation).to receive(:destination_nexus).and_return(destination_hub.nexus)
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
        allow(quotations_quotation).to receive(:pickup_address).and_return(pickup_address)
        allow(quotations_quotation).to receive(:delivery_address).and_return(delivery_address)
      end

      let(:result) {
        [
          original_shipment.imc_reference.to_s,
          "[#{profile.external_id}]",
          "#{pickup_address.country.code}-#{pickup_address.zip_code}",
          "#{delivery_address.country.code}-#{delivery_address.zip_code}",
          cargo_total_weight,
          cargo_total_volume
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
        allow(quotations_quotation).to receive(:pickup_address).and_return(umlaut_address)
        allow(quotations_quotation).to receive(:delivery_address).and_return(delivery_address)
      end

      let(:email_subject) do
        [
          original_shipment.imc_reference.to_s,
          "[#{profile.external_id}]",
          "#{umlaut_address.city} - #{delivery_address.city}",
          cargo_total_weight,
          cargo_total_volume
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
