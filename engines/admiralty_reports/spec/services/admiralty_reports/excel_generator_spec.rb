# frozen_string_literal: true

module AdmiraltyReports
  RSpec.describe ExcelGenerator, type: :service do
    describe '#process_excel_file' do
      let(:tenant) {
        FactoryBot.create(:legacy_tenant,
                          name: 'Test Tenant')
      }
      let(:user) {
        FactoryBot.create(:legacy_user,
                          email: 'imc@imc.com')
      }
      let(:raw_data) do
        [
          FactoryBot.build(:legacy_shipment,
                            user: user,
                            tenant: tenant,
                            updated_at: Date.new(2019, 2, 3),
                            created_at: Date.new(2019, 2, 2),
                            status: 'accepted'),
          FactoryBot.build(:legacy_shipment,
                            user: user,
                            tenant: tenant,
                            updated_at: DateTime.new(2019, 2, 5),
                            created_at: DateTime.new(2019, 2, 4)
                          )
        ]
      end

      subject { ExcelGenerator.generate(raw_data: raw_data).process_excel_file }

      context 'when custom fields are not specified' do
        let(:expected_headers) do
          ['Tenant Name', 'Date of Quotation/Booking', 'User', 'Agency', 'Status']
        end

        let(:expected_info) do
          ['Test Tenant', DateTime.new(2019, 2, 3), 'imc@imc.com', nil, 'accepted']
        end

        it 'should create excel of data from given document' do
          generated_file = Roo::Excelx.new(subject.to_stream)
          expect(generated_file.row(1)).to eq(expected_headers)
          expect(generated_file.row(2)).to eq(expected_info)
        end
      end
    end
  end
end
