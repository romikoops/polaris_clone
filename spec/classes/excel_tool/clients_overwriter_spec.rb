# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelTool::ClientsOverwriter do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:xlsx) { instance_double('xlsx') }

  describe '.parse' do
    let(:options) do
      {
        params: { xlsx: file_fixture('excel').join('dummy.xlsx').to_s },
        _user: user,
        sandbox: nil
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
      allow(sheet_double).to receive(:parse).and_return(dummy_clients_data)
      allow(xlsx).to receive(:sheet).and_return(sheet_double)
      allow(xlsx).to receive(:sheets).and_return(['Clients'])
      allow(Roo::Spreadsheet).to receive(:open).and_return(xlsx)
    end

    it 'returns successfully' do
      result = parser.perform
      expect(result[:stats][:clients][:number_created]).to eq(9)
    end
  end
end
