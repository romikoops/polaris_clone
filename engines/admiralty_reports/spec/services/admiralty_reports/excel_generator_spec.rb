# frozen_string_literal: true

module AdmiraltyReports
  RSpec.describe ExcelGenerator, type: :service do
    describe '#process_excel_file' do
      let(:tenant) { FactoryBot.create(:legacy_tenant, name: 'Test Tenant') }
      let(:quotation_tenant) { FactoryBot.create(:tenants_tenant, slug: 'quotetenant') }
      let(:user) { FactoryBot.create(:legacy_user, email: 'imc@imc.com') }

      let(:raw_request_data) do
        [
          FactoryBot.build(:legacy_shipment,
                           user: user,
                           tenant: tenant,
                           updated_at: Date.new(2020, 2, 3),
                           created_at: Date.new(2020, 2, 2),
                           status: 'accepted'),
          FactoryBot.build(:quotations_quotation,
                           tenant: quotation_tenant,
                           user: user,
                           updated_at: DateTime.new(2020, 2, 3),
                           created_at: DateTime.new(2020, 2, 1))
        ]
      end

      context 'when custom fields are not specified' do
        subject { described_class.generate(raw_request_data: raw_request_data).process_excel_file }

        let(:expected_headers) { ['Tenant Name', 'Date of Quotation/Booking', 'User', 'Company', 'Status'] }

        let(:expected_shipment) { ['Test Tenant', DateTime.new(2020, 2, 3), 'imc@imc.com', nil, 'accepted'] }

        let(:expected_quotation) { ['quotetenant', DateTime.new(2020, 2, 3), 'imc@imc.com', nil, nil] }

        let(:generated_file) { Roo::Excelx.new(subject.to_stream) }

        it 'creates headers correctly' do
          expect(generated_file.row(1)).to eq(expected_headers)
        end

        it 'creates excel with a shipment' do
          expect(generated_file.row(2)).to eq(expected_shipment)
        end

        it 'creates excel with a quotation' do
          expect(generated_file.row(3)).to eq(expected_quotation)
        end
      end
    end
  end
end
