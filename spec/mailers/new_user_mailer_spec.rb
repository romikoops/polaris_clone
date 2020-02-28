# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewUserMailer, type: :mailer do
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { create(:user, tenant: tenant, with_profile: true) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    FactoryBot.create(:tenants_theme, tenant: tenants_tenant)
  end

  describe 'new user email' do
    let(:mail) { described_class.new_user_email(user_id: user.id).deliver_now }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('A New User Has Registered!')
    end

    it 'renders the correct sender' do
      aggregate_failures do
        expect(mail.from).to eq(['no-reply@itsmycargo.test'])
        expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      end
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.tenant.emails.dig('sales', 'general')])
    end
  end
end
