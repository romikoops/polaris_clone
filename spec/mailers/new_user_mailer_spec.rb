# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewUserMailer, type: :mailer do
  let(:user) { create(:user) }

  describe 'new user email' do
    let(:mail) { described_class.new_user_email(user_id: user.id).deliver_now }

    it 'renders the correct subject' do
      expect(mail.subject).to eq('A New User Has Registered!')
    end

    it 'renders the correct sender' do
      expect(mail.from).to eq(['no-reply@itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
    end

    it 'renders the correct receiver' do
      expect(mail.to).to eq([user.tenant.emails.dig('sales', 'general')])
    end
  end

end
