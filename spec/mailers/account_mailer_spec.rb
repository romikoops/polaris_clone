# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountMailer, type: :mailer, skip: true do
  let(:user) { create(:organizations_user) }
  let(:organization) { user.organization }
  let(:profile) { FactoryBot.build(:profiles_profile) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, "#{Settings.breezy.url}/render/html").to_return(status: 201, body: '', headers: {})
    allow(Profiles::ProfileService).to receive(:fetch).and_return(Profiles::ProfileDecorator.new(profile))
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe 'confirmation_instructions' do
    let(:mail) do
      described_class.confirmation_instructions(user, user.send_confirmation_instructions)
    end

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Demo Account Confirmation Email')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders a body with the correct text' do
      expect(mail.body.encoded).to match('Thank you for registering')
    end
  end

  describe 'reset_password_instructions' do
    let(:mail) do
      described_class.reset_password_instructions(user, user.send_reset_password_instructions)
    end

    it 'renders the correct subject' do
      expect(mail.subject).to eq('Demo Account Password Reset')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.shop'])
      expect(mail.reply_to).to eq(['support@demo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders a body with the correct text' do
      expect(mail.html_part.body).to match('Change my password')
    end
  end
end
