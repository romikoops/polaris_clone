# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuoteMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:quotation) { create(:quotation) }

  before do
    stub_request(:get, 'https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png').to_return(status: 200, body: '', headers: {})
    stub_request(:get, 'https://assets.itsmycargo.com/assets/logos/logo_box.png').to_return(status: 200, body: '', headers: {})
    stub_request(:post, 'https://breezypdf.itsmycargo.tech/render/html').to_return(status: 201, body: '', headers: {})
  end

  describe 'quotation_email' do
    let(:mail) { described_class.quotation_email(quotation.shipment, quotation.shipments, user.email, quotation).deliver_now }

    it 'renders', :aggregate_failures, pending: 'no factory' do
      expect(mail.subject).to eq('Your booking through Demo')
      expect(mail.from).to eq(['no-reply@demo.itsmycargo.test'])
      expect(mail.reply_to).to eq(['support@itsmycargo.com'])
      expect(mail.to).to eq(['sales.general@demo.com'])
    end
  end
end
