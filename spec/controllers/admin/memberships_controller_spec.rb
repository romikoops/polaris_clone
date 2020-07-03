# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::MembershipsController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { create(:organizations_user, :with_profile, organization: organization) }

  before do
    ::Organizations.current_id = organization.id
    append_token_header
  end

  describe 'POST #bulk_edit' do
    let(:group_a) { create(:groups_group, organization: organization, name: 'Group A') }
    let(:group_b) { create(:groups_group, organization: organization, name: 'Group B') }
    let!(:user_a) { create(:organizations_user, organization: organization) }
    let(:company_a) { create(:companies_company, organization: organization) }
    let(:company_b) { create(:companies_company, organization: organization) }
    let!(:membership_a) { create(:groups_membership, group: group_a, member: user_a) }
    let!(:membership_b) { create(:groups_membership, group: group_b, member: user_a) }
    let(:edit_params) {
      {
        addedGroups: [group_a.id],
        targetId: user_a.id,
        targetType: 'user',
        memberships:
         [{ id: membership_a.id,
            member_type: 'Organizations::User',
            member_id: user.id,
            group_id: group_a.id,
            priority: 2,
            created_at: '2019-05-09T15:38:08.435Z',
            updated_at: '2019-05-09T15:38:08.435Z',
            member_name: 'Agent IMC',
            human_type: 'client',
            member_email: 'agent@itsmycargo.com',
            original_member_id: user_a.id }],
        organization_id: user.organization_id
      }
    }

    it 'returns http success' do
      post :bulk_edit, params: edit_params

      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['success']).to eq true
      expect(json.dig('data').length).to eq 1
      expect(json.dig('data', 0, 'priority')).to eq 2
    end
  end

  describe 'DELETE #destroy' do
    let(:group) { create(:groups_group, organization: organization, name: 'Discount') }
    let(:membership_user) { create(:organizations_user, organization: organization) }
    let(:membership) { create(:groups_membership, group: group, member: membership_user) }

    it 'destroys the membership' do
      delete :destroy, params: { id: membership.id, organization_id: organization.id }
      expect(Groups::Membership.find_by(id: membership.id)).to be(nil)
    end

    it 'returns an error when membership is not deleted' do
      allow(controller).to receive(:membership).and_return(instance_double('Membership',
                                                                           destroy: false,
                                                                           group: group,
                                                                           errors: ['error']))

      delete :destroy, params: { id: membership.id, organization_id: organization.id }
      expect(JSON.parse(response.body)['data']).to eq(['error'])
    end
  end

  describe 'GET #index' do
    let(:group) { create(:groups_group, organization: organization, name: 'Discount') }
    let(:membership_user) { user }
    let!(:membership) { create(:groups_membership, group: group, member: membership_user) }

    it 'returns the memberships for a specific user' do
      get :index, params: { targetId: user.id, targetType: 'user', organization_id: organization.id }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        json = JSON.parse(response.body)
        expect(json['data'].pluck('id')).to match_array([membership.id])
      end
    end
  end
end
