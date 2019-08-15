# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::GroupsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:user) { create(:legacy_user, tenant: tenant, email: 'user@itsmycargo.com') }
  let!(:role) { create(:role, name: 'shipper') }

  describe 'GET #index' do
    let!(:groups) { create_list(:tenants_group, 5, tenant: tenants_tenant) }
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)

      get :index, params: { tenant_id: tenant.id }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)

      expect(json['success']).to eq true
      expect(json.dig('data', 'numPages')).to eq 1
      expect(json.dig('data', 'groupData').map { |c| c['id'] }.sort).to eq groups.map(&:id).sort
    end
  end

  describe 'POST #create' do
    let(:create_params) {
      { 'addedMembers' =>
        { 'clients' =>
          [user.as_json],
          'groups' => [],
          'companies' => [] },
        'name' => 'Test',
        'tenant_id' => tenant.id,
        'group' => { 'name' => 'Test' } }
    }
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      post :create, params: create_params
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'name')).to eq 'Test'
      expect(::Tenants::Group.find(json.dig('data', 'id')).members.map { |c| c['id'] }).to eq [user.id]
    end
  end

  describe 'POST #edit_members' do
    let(:edit_group) { create(:tenants_group, tenant: tenants_tenant, name: 'Test') }
    let!(:user_a) { create(:legacy_user, tenant: tenant) }
    let!(:user_b) { create(:legacy_user, tenant: tenant) }
    let(:company_a) { create(:tenants_company, tenant: tenants_tenant) }
    let(:company_b) { create(:tenants_company, tenant: tenants_tenant) }
    let!(:membership_a) { create(:tenants_membership, group: edit_group, member: Tenants::User.find_by(legacy_id: user_b.id)) }
    let!(:membership_b) { create(:tenants_membership, group: edit_group, member: company_b) }
    let(:edit_params) {
      { 'addedMembers' =>
        { 'clients' =>
          [user_a.as_json],
          'groups' => [],
          'companies' => [company_a.as_json] },
        'name' => 'Test',
        'tenant_id' => tenant.id,
        'id' => edit_group.id }
    }
    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      post :edit_members, params: edit_params
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data', 'name')).to eq 'Test'
      expect(::Tenants::Group.find(json.dig('data', 'id')).members.map { |c| c['id'] }).to eq [user_a.id, company_a.id]
    end
  end
end
