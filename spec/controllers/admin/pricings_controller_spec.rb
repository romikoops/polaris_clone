# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::PricingsController, type: :controller do
  describe 'POST #upload' do
    context 'error testing' do
      let(:errors_arr) do
        [{ row_no: 1, reason: 'A' },
         { row_no: 2, reason: 'B' },
         { row_no: 3, reason: 'C' },
         { row_no: 4, reason: 'D' }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      before do
        expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
        expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
        expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
        expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(double('Tenant', scope: {}, subdomain: 'test', id: 1))
        expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
        expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1, mot: 'ocean', load_type: 'cargo_item' }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
      end
    end
  end
end
