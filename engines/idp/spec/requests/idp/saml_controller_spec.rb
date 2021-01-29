# frozen_string_literal: true

require "rails_helper"

RSpec.describe IDP::SamlController, type: :request do
  # routes { IDP::Engine.routes }

  let!(:saml_metadatum) { FactoryBot.create(:organizations_saml_metadatum, organization: organization) }
  let(:organization) {
    FactoryBot.create(:organizations_organization,
      domains: [organizations_domain],
      theme: FactoryBot.build(:organizations_theme))
  }
  let(:saml_response) { file_fixture("idp/saml_response").read }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:organizations_domain) { FactoryBot.create(:organizations_domain, domain: "test.host", default: true) }
  let(:user_groups) {
    OrganizationManager::GroupsService.new(target: user, organization: organization).fetch
  }
  let(:one_login) { double("OneLogin::RubySaml::Response", is_valid?: true) }

  before do
    host! "idp.itsmycargo.test"
  end

  around do |example|
    Timecop.freeze(Time.zone.parse("2020-11-09 16:39:34 UTC")) do
      example.run
    end
  end

  describe "GET init" do
    it "redirects to SAML login" do
      get "/saml/#{saml_metadatum.organization_id}/init"

      expect(response.location).to start_with("https://accounts.google.com/o/saml2")
    end
  end

  describe "GET metadata" do
    it "return correct metadata" do
      get "/saml/#{saml_metadatum.organization_id}/metadata"

      expect(response.body).to include("entityID='https://idp.itsmycargo.shop/saml/#{organization.id}/metadata'")
    end
  end

  describe "POST #consume" do
    let(:redirect_location) { response.location }
    let(:response_params) { Rack::Utils.parse_nested_query(redirect_location.split("success?").second) }
    let(:created_user) { Users::Client.unscoped.find_by(id: response_params["userId"], organization_id: organization.id) }
    let(:attributes) { {"firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "customerID" => ["ABCDE"]} }
    let(:saml_attributes) { OneLogin::RubySaml::Attributes.new(attributes) }
    let(:expected_keys) { ["access_token", "created_at", "expires_in", "organizationId", "refresh_token", "scope", "token_type", "userId"] }

    before do
      allow(OneLogin::RubySaml::Response).to receive(:new).and_return(one_login)
      allow(one_login).to receive(:name_id).and_return(user.email)
      allow(one_login).to receive(:attributes).and_return(saml_attributes)
    end

    context "with successful login" do
      it "returns an http status of success" do
        post "/saml/#{organization.id}/consume", params: {SAMLResponse: saml_response}
        expect(response.location).to start_with("https://test.host/login/saml/success")
      end

      it "assigns the external user id" do
        post "/saml/#{organization.id}/consume", params: {SAMLResponse: saml_response}

        expect(Users::ClientProfile.find_by(user_id: created_user.id).external_id).to eq attributes["customerID"][0]
      end
    end

    context "with successful login and group param present" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let(:attributes) { {"firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "groups" => [group.name]} }

      before do
        post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}
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
          "firstName" => ["Test"],
          "lastName" => ["User"],
          "phoneNumber" => [123_456_789],
          "groups" => [group.name, group_2.name]
        }
      }

      before do
        FactoryBot.create(:groups_membership, group: group_3, member: user)
        post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}
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
        expect(user_groups).to match_array([group, group_2, default_group])
      end
    end

    context "with company params" do
      let(:external_id) { "companyid" }
      let!(:country) { FactoryBot.create(:legacy_country, code: "sweet_country") }
      let(:company_membership) {
        Companies::Membership.find_by(member: created_user, company: company)
      }
      let(:company) {
        Companies::Company.find_by(external_id: external_id, organization: organization)
      }
      let(:address_params) {
        {"address_1" => ["add_1"], "address_2" => ["add_2"], "address_3" => ["add_3"],
         "street" => ["street"], "house_number" => ["123"], "zip" => ["zip"], "city" => ["sweet_home"], "country" => ["sweet_country"]}
      }

      let(:address_attributes) {
        {"address_line_1" => address_params["address_1"].first,
         "address_line_2" => address_params["address_2"].first,
         "address_line_3" => address_params["address_3"].first,
         "street" => address_params["street"].first,
         "street_number" => address_params["house_number"].first,
         "zip_code" => address_params["zip"].first,
         "city" => address_params["city"].first,
         "country_id" => country.id}
      }

      context "when company is present" do
        let(:attributes) {
          {"firstName" => ["Test"],
           "companyID" => [external_id],
           "companyName" => ["companyname"]}.merge(address_params)
        }

        before do
          FactoryBot.create(:companies_company,
            external_id: external_id,
            organization: organization)
          post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}
        end

        it "updates the company name" do
          expect(company.name).to eq(saml_attributes[:companyName])
        end

        it "updates the company address" do
          expect(company.address.attributes).to include(address_attributes)
        end

        it "attaches the user to the target company" do
          expect(company_membership).to be_present
        end
      end

      context "when company is not present" do
        let(:attributes) { {"firstName" => ["Test"], "companyID" => [external_id], "companyName" => ["new_company"]}.merge(address_params) }

        before do
          post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}
        end

        it "creates a new company" do
          expect(company).to be_present
        end

        it "assigns the company name" do
          expect(company.name).to eq("new_company")
        end

        it "assigns the company address" do
          expect(company.address.attributes).to include(address_attributes)
        end

        it "attaches the user to the target company" do
          expect(company_membership).to be_present
        end
      end
    end

    context "when profile fails to create" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let(:attributes) { {"firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "groups" => [group.name]} }

      before do
        allow(Users::Client).to receive(:find_or_initialize_by).and_raise(ActiveRecord::RecordInvalid)
      end

      it "does not create a user without profile" do
        post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end

  context "with unsuccessful login" do
    describe "POST #consume (failed login)" do
      it "redirects to error url when the response is not valid" do
        post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end

  context "when organization is not found" do
    describe "POST #consume (no organization)" do
      it "redirects to error url when the response is not valid" do
        post "/saml/#{organization.id}/consume", params: {id: organization.id, SAMLResponse: saml_response}

        expect(response.location).to eq("https://test.host/login/saml/error")
      end
    end
  end
end
