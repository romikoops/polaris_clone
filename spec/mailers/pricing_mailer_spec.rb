# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PricingMailer, type: :mailer do
  let(:user) { create(:user, with_profile: false) }
  let(:pricing) { create(:pricing) }

  before do
    create(:profiles_profile,
           first_name: 'John',
           last_name: 'Doe',
           user_id: Tenants::User.find_by(legacy_id: user.id).id)
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, "#{Settings.breezy.url}/render/html").to_return(status: 201, body: '', headers: {})
  end

  describe 'request_email' do
    let(:mail) { described_class.request_email(user_id: user.id, pricing_id: pricing.id, tenant_id: pricing.tenant.id).deliver_now }

    it 'renders', :aggregate_failures do
      expect(mail.subject).to eq('New Rate Request for Gothenburg - Shanghai from John Doe')
      expect(mail.from).to eq(['no-reply@itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end
end
