# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeMailer do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }

  before do
    create(:legacy_content, component: 'WelcomeMail', section: 'subject', text: 'WELCOME_EMAIL', tenant_id: tenant.id)
    create(:legacy_content, component: 'WelcomeMail', section: 'body', text: 'WELCOME_EMAIL', tenant_id: tenant.id)
    create(:legacy_content, component: 'WelcomeMail', section: 'social', text: 'WELCOME_EMAIL', tenant_id: tenant.id)
    create(:legacy_content, component: 'WelcomeMail', section: 'footer', text: 'WELCOME_EMAIL', tenant_id: tenant.id)

    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/tenants/normanglobal/ngl_welcome_image.jpg').to_return(status: 200, body: '', headers: {})
    stub_request(:post, "#{Settings.breezy.url}/render/html").to_return(status: 201, body: '', headers: {})
  end

  describe 'welcome_email', :aggregate_failures do
    let(:mail) do
      described_class.welcome_email(user)
    end

    it 'renders correctly' do
      expect(mail.subject).to eq('WELCOME_EMAIL')
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to match('WELCOME_EMAIL')
    end
  end
end
