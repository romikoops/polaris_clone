# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ClientsController do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:authentication_user, :users_user) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
    append_token_header
  end

  describe "GET #index" do
    let(:organization_2) { FactoryBot.create(:organizations_organization, slug: "demo2") }
    let(:company) { FactoryBot.create(:companies_company, name: "ItsMyCargo", organization_id: organization_2.id) }
    let(:users) do
      [{
        first_name: "A Test",
        last_name: "A User",
        email: "atestuser@itsmycargo.com"
      },
        {
          first_name: "B Test",
          last_name: "B User",
          email: "btestuser@itsmycargo.com"
        },
        {
          first_name: "C Test",
          last_name: "C User",
          email: "ctestuser@itsmycargo.com"
        }]
    end

    before do
      ::Organizations.current_id = organization_2.id
      users.each do |user_details|
        user = FactoryBot.create(:users_user,
          email: user_details[:email],
          organization_id: organization_2.id)
        FactoryBot.create(:companies_membership, company: company, member: user)
        FactoryBot.create(:profiles_profile,
          first_name: user_details[:first_name],
          last_name: user_details[:last_name],
          user_id: user.id)
      end
    end

    it "returns an http status of success" do
      get :index, params: {organization_id: organization_2.id}
      expect(response).to have_http_status(:success)
    end

    context "with query search" do
      it "returns the correct matching results with search" do
        get :index, params: {organization_id: organization_2.id, query: "btestuser"}
        resp = JSON.parse(response.body)
        expect(resp["data"]["clientData"].first["email"]).to eq("btestuser@itsmycargo.com")
      end
    end

    context "when searching via company names" do
      it "returns users matching the given company_name " do
        get :index, params: {organization_id: organization_2.id, company_name: "ItsMyCargo"}
        resp = JSON.parse(response.body)

        expect(resp["data"]["clientData"].pluck("email")).to include(users.sample[:email])
      end
    end

    shared_examples_for "A searchable & orderable collection" do |search_keys|
      search_keys.each do |search_key|
        context "#{search_key} search & ordering" do
          it "yields the correct matching results for search" do
            sample_user = users.sample
            get :index, params: {search_key => sample_user[search_key.to_sym], :organization_id => organization_2.id}
            resp = JSON.parse(response.body)
            expect(resp["data"]["clientData"].first[search_key.camelize(:lower)]).to eq(sample_user[search_key.to_sym])
          end

          it "sorts the result according to the param provided" do
            expected_response = users.pluck(search_key.to_sym).sort.reverse
            get :index, params: {"#{search_key}_desc" => "true", :organization_id => organization_2.id}
            resp = JSON.parse(response.body)
            expect(resp["data"]["clientData"].pluck(search_key.camelize(:lower))).to eq(expected_response)
          end
        end
      end
    end
    it_behaves_like "A searchable & orderable collection", %w[first_name last_name email]
  end

  describe "GET #show" do
    let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }

    it "returns an http status of success" do
      post :show, params: {organization_id: organization, id: user}
      expect(response).to have_http_status(:success)
    end
  end

  describe "post #create" do
    let(:email) { "email123@demo.com" }
    let(:user_attributes) {
      FactoryBot.attributes_for(:organizations_user, email: email).deep_transform_keys { |k| k.to_s.camelize(:lower) }
    }
    let(:profile_params) { FactoryBot.attributes_for(:profiles_profile) }
    let(:profile_attributes) { profile_params.deep_transform_keys { |k| k.to_s.camelize(:lower) } }
    let(:attributes) { user_attributes.merge(profile_attributes) }
    let(:created_profile_attrs) { Profiles::Profile.last.attributes }

    before do
      FactoryBot.create(:organizations_theme, organization: organization)
    end

    it "returns an http status of success" do
      post :create, params: {organization_id: organization, new_client: attributes.to_json}
      expect(response).to have_http_status(:success)
    end

    it "creates the user" do
      post :create, params: {organization_id: organization, new_client: attributes.to_json}
      expect(Users::User.where(organization_id: organization.id).last.email).to eq(attributes["email"])
    end

    it "assigns profile the correct params" do
      post :create, params: {organization_id: organization, new_client: attributes.to_json}

      expect(Profiles::Profile.last.attributes.symbolize_keys).to include(profile_params)
    end

    context "when profile fails to create" do
      before do
        allow(Profiles::Profile).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "does not create a user without profile" do
        post :create, params: {organization_id: organization, new_client: attributes.to_json}

        aggregate_failures do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(Users::User.find_by(organization_id: organization.id, email: attributes[:email])).not_to be_present
        end
      end
    end

    context "when creating client with email belonging to a soft deleted user" do
      let(:organization_2) { FactoryBot.create(:organizations_organization) }
      let(:user) do
        FactoryBot.create(:organizations_user,
          :with_profile,
          email: "email123@demo.com",
          organization: organization)
      end
      let(:user_2) do
        FactoryBot.create(:organizations_user,
          :with_profile,
          email: "email123@demo.com",
          organization: organization_2)
      end

      before do
        user.destroy
        user_2.destroy
      end

      it "restores the user and restores corresponding relationships" do
        post :create, params: {organization_id: organization, new_client: attributes.to_json}

        restored_user = Organizations::User.find_by(email: "email123@demo.com", organization: organization)
        aggregate_failures do
          expect(user_2.deleted?).to eq(true)
          expect(Users::Settings.where(user_id: restored_user.id)).to exist
          expect(Profiles::Profile.where(user_id: restored_user.id)).to exist
        end
      end
    end

    context "when user is restored and the associations are permanently deleted" do
      let(:email) { "email1234@demo.com" }
      let(:user) do
        FactoryBot.create(:organizations_user,
          :with_profile,
          email: "email1234@demo.com",
          organization: organization)
      end

      before do
        user.destroy
        Profiles::Profile.find_by(user_id: user).really_delete
        Users::Settings.find_by(user_id: user).really_delete
      end

      it "creates new associations with defaults" do
        post :create, params: {organization_id: organization, new_client: attributes.to_json}

        restored_user = Organizations::User.find_by(email: email, organization: organization)
        aggregate_failures do
          expect(Users::Settings.where(user_id: restored_user.id)).to exist
          expect(Profiles::Profile.where(user_id: restored_user.id)).to exist
        end
      end
    end
  end

  describe "POST #agents" do
    let(:perform_request) { post :agents, params: {organization_id: organization, file: file} }
    let(:uploader) { double(perform: nil) }
    let(:file) { fixture_file_upload("spec/fixtures/files/excel/dummy.xlsx") }

    it_behaves_like "uploading request async"
  end

  describe "DELETE #destroy" do
    let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    before do
      FactoryBot.create(:groups_membership, group: group, member: user)
      FactoryBot.create(:companies_membership, company: company, member: user)
    end

    it "returns an http status of success" do
      delete :destroy, params: {organization_id: organization, id: user.id}
      expect(response).to have_http_status(:success)
    end

    it "deletes the users group membership" do
      delete :destroy, params: {organization_id: organization, id: user.id}
      expect(Groups::Membership.exists?(member: user)).to be false
    end

    it "deletes the users company memberships" do
      delete :destroy, params: {organization_id: organization, id: user.id}
      expect(Companies::Membership.where(member: user)).to_not exist
    end

    it "deletes the user" do
      delete :destroy, params: {organization_id: organization, id: user.id}
      expect(Users::User.find_by(id: user.id)).to be(nil)
    end
  end
end
