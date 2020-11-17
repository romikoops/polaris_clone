# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewUserMailer, type: :mailer do
  let(:user) { FactoryBot.create(:organizations_user) }
  let(:organization) { user.organization }
  let(:profile) { FactoryBot.build(:profiles_profile) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})

    allow(Profiles::ProfileService).to receive(:fetch).and_return(Profiles::ProfileDecorator.new(profile))
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe 'new user email' do
    let(:mail) { described_class.new_user_email(user: user).deliver_now }

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
      expect(mail.to).to eq([organization.theme.emails.dig('sales', 'general')])
    end
  end
end
