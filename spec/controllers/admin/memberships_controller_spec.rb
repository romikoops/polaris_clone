# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MembershipsController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }

  before do
    allow(controller).to receive(:user_signed_in?).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:require_login_and_role_is_admin).and_return(true)
  end

  describe 'POST #bulk_edit' do
    let(:group_a) { create(:tenants_group, tenant: tenants_tenant, name: 'Group A') }
    let(:group_b) { create(:tenants_group, tenant: tenants_tenant, name: 'Group B') }
    let!(:user_a) { create(:legacy_user, tenant: tenant) }
    let!(:tenants_user_a) { Tenants::User.find_by(legacy_id: user_a.id) }
    let(:company_a) { create(:tenants_company, tenant: tenants_tenant) }
    let(:company_b) { create(:tenants_company, tenant: tenants_tenant) }
    let!(:membership_a) { create(:tenants_membership, group: group_a, member: tenants_user_a) }
    let!(:membership_b) { create(:tenants_membership, group: group_b, member: tenants_user_a) }
    let(:edit_params) {
      {
        addedGroups: [group_a.id],
        targetId: user_a.id,
        targetType: 'user',
        memberships:
         [{ id: membership_a.id,
            member_type: 'Tenants::User',
            member_id: tenants_user.id,
            group_id: group_a.id,
            priority: 1,
            created_at: '2019-05-09T15:38:08.435Z',
            updated_at: '2019-05-09T15:38:08.435Z',
            member_name: 'Agent IMC',
            human_type: 'client',
            member_email: 'agent@itsmycargo.com',
            original_member_id: user_a.id }],
        tenant_id: user.tenant_id
      }
    }

    it 'returns http success' do
      allow(controller).to receive(:user_signed_in?).and_return(true)
      allow(controller).to receive(:current_user).and_return(user)
      expect_any_instance_of(described_class).to receive(:require_login_and_role_is_admin).and_return(true)
      post :bulk_edit, params: edit_params
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data').length).to eq 1
      expect(json.dig('data', 0, 'priority')).to eq 0
    end
  end

  describe 'DELETE #destroy' do
    let(:group) { create(:tenants_group, tenant: tenants_tenant, name: 'Discount') }
    let(:membership_user) { create(:tenants_user, tenant: tenants_tenant) }
    let(:membership) { create(:tenants_membership, group: group, member: membership_user) }

    it 'destroys the membership' do
      delete :destroy, params: { id: membership.id, tenant_id: tenant.id }
      expect(Tenants::Membership.find_by(id: membership.id)).to be(nil)
    end

    it 'returns an error when membership is not deleted' do
      allow(controller).to receive(:membership).and_return(instance_double('Membership',
                                                                           destroy: false,
                                                                           group: group,
                                                                           errors: ['error']))

      delete :destroy, params: { id: membership.id, tenant_id: tenant.id }
      expect(JSON.parse(response.body)['data']).to eq(['error'])
    end
  end
end
