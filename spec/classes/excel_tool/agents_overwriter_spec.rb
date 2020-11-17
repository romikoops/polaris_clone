# frozen_string_literal: true

require 'rails_helper'
RSpec.deprecate "ExcelTool::AgentsOverwriter#perform" do
  RSpec.describe ExcelTool::AgentsOverwriter do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:xlsx) { instance_double('xlsx') }

    before do
      stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700").to_return(status: 200, body: "", headers: {})
    end

    describe '.parse' do
      let(:options) do
        {
          params: { xlsx: file_fixture('excel').join('dummy.xlsx').to_s },
          user: user
        }
      end
      let(:dummy_agents_row_data) do
        (1...10).map do |n|
          {
            first_name: 'Test',
            last_name: "Agent #{n}",
            email: "test_agent_#{n}@itsmycargo.com",
            phone: '123456789',
            company_name: 'ItsMyCargo',
            address: '7 Brooktorkai Ave, Hamburg, Germany',
            password: 'password'
          }
        end
      end
      let(:dummy_agency_row_data) do
        (1...10).map do |n|
          {
            first_name: 'Test',
            last_name: "Agency Manager #{n}",
            email: "test_agency_maanager_#{n}@itsmycargo.com",
            phone: '123456789',
            company_name: 'ItsMyCargo',
            address: '7 Brooktorkai Ave, Hamburg, Germany',
            password: 'password'
          }
        end
      end
      let(:parser) { described_class.new(options) }
      let(:agent_parser) { double }
      let(:agency_parser) { double }
      let(:expected_result) do
        {
          agents: { number_updated: 0, number_created: 9 },
          agencies: { number_updated: 8, number_created: 1 },
          agency_managers: { number_updated: 0, number_created: 9 }
        }
      end

      before do
        allow(agent_parser).to receive(:parse).and_return(dummy_agents_row_data)
        allow(xlsx).to receive(:sheet).with('Agents').and_return(agent_parser)
        allow(agency_parser).to receive(:parse).and_return(dummy_agency_row_data)
        allow(xlsx).to receive(:sheet).with('Agencies').and_return(agency_parser)
        allow(Roo::Spreadsheet).to receive(:open).and_return(xlsx)
      end

      it 'returns successfully' do
        expect(parser.perform).to eq(expected_result)
      end
    end
  end
end
