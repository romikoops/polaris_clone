# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mailers::UserMailer, type: :mailer do
  let(:user) { double('User', email: 'john@itsmycargo.test', activation_token: 'ACTIVATION_TOKEN', reset_password_token: 'RESET_TOKEN') }

  describe 'activation_needed_email' do
    let(:mail) { described_class.activation_needed_email(user) }

    it 'renders correctly' do
      aggregate_failures do
        expect(mail.from).to eq ['no-reply@itsmycargo.com']
        expect(mail.reply_to).to eq(nil)
        expect(mail.subject).to eq 'Activation needed email'
      end
    end
  end

  describe 'activation_success_email' do
    let(:mail) { described_class.activation_success_email(user) }

    it 'renders correctly' do
      aggregate_failures do
        expect(mail.from).to eq ['no-reply@itsmycargo.com']
        expect(mail.reply_to).to eq(nil)
        expect(mail.subject).to eq 'Activation success email'
      end
    end
  end

  describe 'reset_password_email' do
    let(:mail) { described_class.reset_password_email(user) }

    it 'renders correctly' do
      aggregate_failures do
        expect(mail.from).to eq ['no-reply@itsmycargo.com']
        expect(mail.reply_to).to eq(nil)
        expect(mail.subject).to eq 'Reset password email'
      end
    end
  end
end
