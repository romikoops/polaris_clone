# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShipmentMailer, type: :mailer do
  let(:organization) { create(:organizations_organization, slug: 'demo') }
  let(:user) { create(:organizations_user, organization: organization) }

  let(:billing) { :external }
  let!(:shipment) {
    create(:complete_legacy_shipment,
      user: user,
      organization: user.organization,
      with_breakdown: true,
      with_tenders: true,
      billing: billing)
  }
  let!(:profile) { FactoryBot.create(:profiles_profile, user: user, external_id: '1234') }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization, name: 'Demo')
  end

  describe 'tenant_notification' do
    let(:mail) { described_class.tenant_notification(user, shipment).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      expect(mail.to).to eq(["sales.general@demo.com"])
    end
  end

  describe 'shipper_notification' do
    let(:mail) { described_class.shipper_notification(user, shipment).deliver_now }

    context 'when shipment is external' do
      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@demo.com'])
        expect(mail.to).to eq([user.email])
      end
    end

    context 'when shipment is internal' do
      let(:billing) { :internal }

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@demo.com'])
        expect(mail.to).to eq([Settings.emails.booking])
      end
    end

    context 'when shipment is test' do
      let(:billing) { :test }

      it 'renders', :aggregate_failures do
        expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
        expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
        expect(mail.reply_to).to eq(['support@demo.com'])
        expect(mail.to).to eq([Settings.emails.booking])
      end
    end
  end

  describe 'shipper_confirmation' do
    let(:mail) { described_class.shipper_confirmation(user, shipment).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq("FCL Booking: Gothenburg - Gothenburg, Refs: #{shipment.imc_reference}")
      expect(mail.from).to eq(["no-reply@#{organization.slug}.itsmycargo.shop"])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
    end
  end
end
