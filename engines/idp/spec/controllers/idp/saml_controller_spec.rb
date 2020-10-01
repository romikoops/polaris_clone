# frozen_string_literal: true

require "rails_helper"

RSpec.describe IDP::SamlController, type: :controller do
  routes { IDP::Engine.routes }

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:saml_response) { FactoryBot.build(:idp_saml_response) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:default_group) { Groups::Group.find_by(name: "default", organization: organization) }
  let!(:organizations_domain) { FactoryBot.create(:organizations_domain, domain: "test.host", organization: organization, default: true) }
  let(:forwarded_host) { organizations_domain.domain }
  let(:expected_keys) { %w[access_token created_at expires_in organizationId refresh_token scope token_type userId] }
  let(:user_groups) {
    OrganizationManager::HierarchyService.new(target: user, organization: organization).fetch
      .select { |hier| hier.is_a?(Groups::Group) }
  }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    FactoryBot.create(:organizations_saml_metadatum, organization: organization)
    request.headers["Host"] = "idp.itsmycargo.test"
  end

  describe "GET init" do
    it "redirects to SAML login" do
      get :init, params: {id: organization.id}

      expect(response.location).to start_with("https://accounts.google.com/o/saml2")
    end
  end

  describe "GET metadata" do
    it "return correct metadata" do
      get :metadata, params: {id: organization.id}

      expect(response.body).to include("entityID='https://idp.itsmycargo.shop/saml/#{organization.id}/metadata'")
    end
  end

  describe "POST #consume" do
    let(:one_login) { instance_double("OneLogin::RubySaml::Response", is_valid?: true) }
    let(:attributes) { {firstName: "Test", lastName: "User", phoneNumber: 123_456_789} }
    let(:redirect_location) { response.location }
    let(:response_params) { Rack::Utils.parse_nested_query(redirect_location.split("success?").second) }
    let(:created_user) { Organizations::User.unscoped.find_by(id: response_params["userId"], organization_id: organization.id) }

    before do
      allow(one_login).to receive(:is_valid?).and_return(true)
      allow(one_login).to receive(:name_id).and_return("test@itsmycargo.com")
      allow(one_login).to receive(:attributes).and_return(attributes)
      allow(controller).to receive(:saml_response).and_return(one_login)
    end

    context "with successful login" do
      it "returns an http status of success" do
        post :consume, params: {id: organization.id, SAMLResponse: {}}

        aggregate_failures do
          expect(response.status).to eq(302)
          expect(response_params.keys).to match_array(expected_keys)
          expect(response_params["organizationId"]).to eq(organization.id)

          expect(created_user).to be_present
        end
      end
    end

    context "with successful login and group param present" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let(:attributes) { {firstName: "Test", lastName: "User", phoneNumber: 123_456_789, groups: [group.name]} }

      before do
        allow(one_login).to receive(:name_id).and_return(user.email)
        post :consume, params: {id: organization.id, SAMLResponse: {}}
      end

      it "returns an http status of success" do
        aggregate_failures do
          expect(response.status).to eq(302)
          expect(response_params.keys).to match_array(expected_keys)
          expect(response_params["organizationId"]).to eq(organization.id.to_s)

          expect(created_user).to be_present
        end
      end

      it "attaches the user to the target group" do
        aggregate_failures do
          expect(user_groups).to match_array([group, default_group])
        end
      end
    end

    context "with successful login and group param and existing present" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let!(:group_2) { FactoryBot.create(:groups_group, name: "Test Group 2", organization: organization) }
      let!(:group_3) { FactoryBot.create(:groups_group, name: "Test Group 3", organization: organization) }
      let(:attributes) {
        {
          firstName: "Test",
          lastName: "User",
          phoneNumber: 123_456_789,
          groups: [group.name, group_2.name]
        }
      }

      before do
        FactoryBot.create(:groups_membership, group: group_3, member: user)
        allow(one_login).to receive(:name_id).and_return(user.email)
        post :consume, params: {id: organization.id, SAMLResponse: {}}
      end

      it "returns an http status of success" do
        aggregate_failures do
          expect(response.status).to eq(302)
          expect(response_params.keys).to match_array(expected_keys)
          expect(response_params["organizationId"]).to eq(organization.id.to_s)

          expect(created_user).to be_present
        end
      end

      it "attaches the user to the target group" do
        aggregate_failures do
          expect(user_groups).to match_array([group, group_2, default_group])
        end
      end
    end

    context "when profile fails to create" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let(:attributes) { {firstName: "Test", lastName: "User", phoneNumber: 123_456_789, groups: [group.name]} }

      before do
        allow(one_login).to receive(:name_id).and_return(user.email)
        allow(Profiles::Profile).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it "does not create a user without profile" do
        post :consume, params: {id: organization.id, SAMLResponse: {}}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end

  context "with unsuccessful login" do
    describe "POST #consume (failed login)" do
      it "redirects to error url when the response is not valid" do
        post :consume, params: {id: organization.id, SAMLResponse: saml_response}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end

  context "when organization is not found" do
    describe "POST #consume (no organization)" do
      it "redirects to error url when the response is not valid" do
        post :consume, params: {id: organization.id, SAMLResponse: saml_response}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end
end
