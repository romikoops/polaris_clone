# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe ExcelGenerator, type: :service do
    describe '#process_excel_file' do
      let(:organization) { FactoryBot.create(:organizations_organization) }
      let(:user) { FactoryBot.create(:organizations_user, email: 'imc@imc.com', organization: organization) }
      let(:shipment) do
        FactoryBot.build(:legacy_shipment,
                         user: user,
                         organization: user.organization,
                         updated_at: Date.new(2020, 2, 3),
                         created_at: Date.new(2020, 2, 1),
                         status: 'accepted')
      end
      let(:quotation) do
        FactoryBot.build(:quotations_quotation,
                         organization: user.organization,
                         user: user,
                         updated_at: DateTime.new(2020, 2, 3),
                         created_at: DateTime.new(2020, 2, 1))
      end

      let(:raw_request_data) do
         [shipment, quotation]
       end

      before do
        ::Organizations.current_id = organization.id
        FactoryBot.create(:companies_company, :with_member, name: 'company', organization: organization, member: user)
      end

      context 'when custom fields are not specified' do
        subject { described_class.generate(raw_request_data: raw_request_data).process_excel_file }

        let(:expected_headers) { ['Tenant Name', 'Date of Quotation/Booking', 'User', 'Company', 'Status'] }

        let(:expected_shipment) { [shipment.organization.slug, Date.new(2020, 2, 1), 'imc@imc.com', 'company', 'accepted'] }

        let(:expected_quotation) { [quotation.organization.slug, Date.new(2020, 2, 1), 'imc@imc.com', 'company', nil] }

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
