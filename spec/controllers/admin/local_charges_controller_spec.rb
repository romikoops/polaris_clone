# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::LocalChargesController, type: :controller do
  describe 'POST #upload' do
    let(:user) { FactoryBot.create(:user) }
    let(:tenant) { FactoryBot.create(:tenant) }

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
        expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(tenant)
        expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(user)
        expect(Document).to receive(:create!)
        expect_any_instance_of(ExcelDataServices::Loaders::Uploader).to receive(:perform).and_return(error)
      end

      it 'returns error with messages when an error is raised' do
        post :upload, params: { 'file' => Rack::Test::UploadedFile.new(File.expand_path('../../test_sheets/spec_sheet.xlsx', __dir__)), tenant_id: 1 }
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(json_response.dig('data', 'errors')).to eq(JSON.parse(errors_arr.to_json))
      end
    end
  end

  describe 'GET #download' do
    let(:tenant) { create(:tenant) }
    let(:hubs) do
      [
        create(:hub,
               tenant: tenant,
               name: 'Gothenburg Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Gothenburg')),
        create(:hub,
               tenant: tenant,
               name: 'Shanghai Port',
               hub_type: 'ocean',
               nexus: create(:nexus, name: 'Shanghai'))
      ]
    end
    let(:tenant_vehicle) do
      create(:tenant_vehicle, tenant: tenant)
    end
    let!(:local_charge) do
      create(
        :local_charge,
        mode_of_transport: 'ocean',
        load_type: 'lcl',
        hub: hubs.first,
        tenant: tenant,
        tenant_vehicle: tenant_vehicle,
        counterpart_hub_id: hubs.second,
        direction: 'export',
        fees: { 'DOC' => { 'key' => 'DOC', 'max' => nil, 'min' => nil, 'name' => 'Documentation', 'value' => 20, 'currency' => 'EUR', 'rate_basis' => 'PER_BILL' } },
        dangerous: nil,
        effective_date: Date.parse('Thu, 24 Jan 2019'),
        expiration_date: Date.parse('Fri, 24 Jan 2020'),
        user_id: nil
      )
    end

    before do
      create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: { 'base_pricing' => true })
      expect_any_instance_of(described_class).to receive(:require_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_non_guest_authentication!).and_return(true)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      expect_any_instance_of(described_class).to receive(:current_tenant).at_least(:once).and_return(tenant)
      expect_any_instance_of(described_class).to receive(:current_user).at_least(:once).and_return(double('User', guest: false, email: 'test@test.com', id: 1, agency_id: nil, agency: nil, tenant: nil, groups: nil, company: nil, scope: nil, sandbox: nil))
    end

    it 'returns error with messages when an error is raised' do
      get :download, params: { tenant_id: tenant.id, options: { mot: nil, group_id: nil } }
      json_response = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(json_response.dig('data', 'url').include?('demo__local_charges_.xlsx')).to be_truthy
    end
  end
end
