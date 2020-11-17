# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelTool::ClientsOverwriter do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:xlsx) { instance_double('xlsx') }

  describe '.parse' do
    let(:options) do
      {
        params: { xlsx: file_fixture('excel').join('dummy.xlsx').to_s },
        _user: user
      }
    end

    let(:dummy_clients_data) do
      (1...10).map do |n|
        {
          first_name: 'Test',
          last_name: "Client #{n}",
          email: "test_client_#{n}@itsmycargo.com",
          phone: '123456789',
          company_name: 'ItsMyCargo',
          address: '7 Brooktorkai Ave, Hamburg, Germany',
          password: 'password'
        }
      end
    end
    let(:sheet_double) { instance_double('sheet') }
    let(:parser) { described_class.new(options) }

    before do
      stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})

      allow(sheet_double).to receive(:parse).and_return(dummy_clients_data)
      allow(xlsx).to receive(:sheet).and_return(sheet_double)
      allow(xlsx).to receive(:sheets).and_return(['Clients'])
      allow(Roo::Spreadsheet).to receive(:open).and_return(xlsx)
      FactoryBot.create(:organizations_theme, organization: organization)
    end

    it 'returns successfully' do
      result = parser.perform
      expect(result[:stats][:clients][:number_created]).to eq(9)
    end
  end
end
