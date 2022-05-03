# frozen_string_literal: true

require "rails_helper"

RSpec.describe IDP::SamlController, type: :request do
  let(:event_store) { Rails.configuration.event_store }
  let!(:saml_metadatum) { FactoryBot.create(:organizations_saml_metadatum, organization: organization) }
  let(:organization) do
    FactoryBot.create(:organizations_organization,
      domains: [organizations_domain],
      theme: FactoryBot.build(:organizations_theme))
  end
  let(:saml_response) { file_fixture("idp/saml_response").read }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:organizations_domain) { FactoryBot.create(:organizations_domain, domain: "test.host", default: true) }
  let(:user_groups) do
    OrganizationManager::GroupsService.new(target: user, organization: organization).fetch
  end
  let(:one_login) { instance_double("OneLogin::RubySaml::Response", is_valid?: true) }
  let(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
  let(:success_event) { event_store.read.stream("Organization$#{organization.id}").of_type([IDP::SamlSuccessfulLogin]).first }

  before do
    FactoryBot.create(:application, name: "dipper")
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

      expect(response.body).to include("entityID='http://idp.itsmycargo.test/saml/#{organization.id}/metadata'")
    end
  end

  describe "POST #consume" do
    let(:redirect_location) { response.location }
    let(:response_params) { Rack::Utils.parse_nested_query(redirect_location.split("success?").second) }
    let(:created_user) { Users::Client.unscoped.find_by(id: response_params["userId"], organization_id: organization.id) }
    let(:base_attributes) { { "firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "customerID" => ["ABCDE"] } }
    let(:attributes) { base_attributes }
    let(:saml_attributes) { OneLogin::RubySaml::Attributes.new(attributes) }
    let(:expected_keys) { %w[access_token created_at expires_in organizationId refresh_token scope token_type userId] }

    before do
      allow(OneLogin::RubySaml::Response).to receive(:new).and_return(one_login)
      allow(one_login).to receive(:name_id).and_return(user.email)
      allow(one_login).to receive(:attributes).and_return(saml_attributes)
    end

    shared_examples_for "SAML consume success" do
      it "returns an http status of success", :aggregate_failures do
        expect(response.status).to eq(302)
        expect(response_params.keys).to match_array(expected_keys)
        expect(response_params["organizationId"]).to eq(organization.id.to_s)

        expect(created_user).to be_present
      end

      it "publishes event" do
        expect(success_event).to be_present
      end
    end

    context "with successful login" do
      it "returns an http status of success" do
        post "/saml/#{organization.id}/consume", params: { SAMLResponse: saml_response }
        expect(response.location).to start_with("https://test.host/login/saml/success")
      end

      it "assigns the external user id" do
        post "/saml/#{organization.id}/consume", params: { SAMLResponse: saml_response }

        expect(Users::ClientProfile.find_by(user_id: created_user.id).external_id).to eq attributes["customerID"][0]
      end

      it "publishes event" do
        post "/saml/#{organization.id}/consume", params: { SAMLResponse: saml_response }

        expect(success_event).to be_present
      end
    end

    context "with successful login and group param present" do
      let(:attributes) { base_attributes.merge("groups" => [group.name]) }

      before do
        post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
      end

      it_behaves_like "SAML consume success"

      it "attaches the user to the target group" do
        expect(user_groups).to match_array([group, default_group])
      end
    end

    context "with successful login and group param and existing present" do
      let!(:second_group) { FactoryBot.create(:groups_group, name: "Test Group 2", organization: organization) }
      let!(:third_group) { FactoryBot.create(:groups_group, name: "Test Group 3", organization: organization) }
      let(:attributes) do
        base_attributes.merge("groups" => [group.name, second_group.name])
      end

      before do
        FactoryBot.create(:groups_membership, group: third_group, member: user)
        post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
      end

      it_behaves_like "SAML consume success"

      it "attaches the user to the target group" do
        expect(user_groups).to match_array([group, second_group, default_group])
      end
    end

    context "with company params" do
      let(:external_id) { "companyid" }
      let!(:country) { FactoryBot.create(:legacy_country, code: "sweet_country") }
      let(:company_membership) do
        Companies::Membership.find_by(client: created_user, company: company, branch_id: external_id)
      end
      let(:company) do
        Companies::Company.find_by(name: saml_attributes[:companyName], organization: organization)
      end
      let(:address_params) do
        { "address_1" => ["add_1"], "address_2" => ["add_2"], "address_3" => ["add_3"],
          "street" => ["street"], "house_number" => ["123"], "zip" => ["zip"], "city" => ["sweet_home"], "country" => ["sweet_country"] }
      end

      let(:address_attributes) do
        { "address_line_1" => address_params["address_1"].first,
          "address_line_2" => address_params["address_2"].first,
          "address_line_3" => address_params["address_3"].first,
          "street" => address_params["street"].first,
          "street_number" => address_params["house_number"].first,
          "zip_code" => address_params["zip"].first,
          "city" => address_params["city"].first,
          "country_id" => country.id }
      end

      context "when company is present" do
        let(:attributes) do
          base_attributes.merge("companyID" => [external_id], "companyName" => ["companyname"]).merge(address_params)
        end

        before do
          FactoryBot.create(:companies_company,
            name: saml_attributes[:companyName],
            organization: organization)
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
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

        it "publishes event" do
          expect(success_event).to be_present
        end
      end

      context "when company is not present" do
        let(:attributes) { base_attributes.merge("companyID" => [external_id], "companyName" => ["new_company"]).merge(address_params) }

        before do
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
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

        it "publishes event" do
          expect(success_event).to be_present
        end
      end

      context "when referrer_host is a Siren domain" do
        let(:attributes) { base_attributes.merge("companyID" => [external_id], "companyName" => ["new_company"]).merge(address_params) }
        let!(:siren_domain) { FactoryBot.create(:organizations_domain, domain: "siren.itsmycargo.com", organization: organization, application_id: siren.id, default: false) }
        let(:siren) { FactoryBot.create(:application, name: "siren") }

        before do
          allow(controller).to receive(:referrer_host).and_return(siren_domain.domain)
          get "/saml/#{saml_metadatum.organization_id}/init", headers: { "HTTP_REFERER" => "https://#{siren_domain.domain}" }
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
        end

        it "returns a token for application listed on the Domain matching the referrer host" do
          expect(Doorkeeper::AccessToken.find_by(token: response_params["access_token"]).application).to eq(siren)
        end
      end

      context "when referrer_host is a Siren review app domain" do
        let(:attributes) { base_attributes.merge("companyID" => [external_id], "companyName" => ["new_company"]).merge(address_params) }
        let!(:siren_domain) { FactoryBot.create(:organizations_domain, domain: "siren-%.itsmycargo.dev", organization: organization, application_id: siren.id, default: false) }
        let(:siren) { FactoryBot.create(:application, name: "siren") }

        before do
          allow(controller).to receive(:referrer_host).and_return(siren_domain.domain)
          get "/saml/#{saml_metadatum.organization_id}/init", headers: { "HTTP_REFERER" => "https://siren-sir-999.itsmycargo.dev" }
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }
        end

        it "returns a token for application listed on the Domain matching the referrer host" do
          expect(Doorkeeper::AccessToken.find_by(token: response_params["access_token"]).application).to eq(siren)
        end
      end
    end

    context "with unsuccessful login" do
      let(:error_from_event) do
        event_store
          .read
          .stream("Organization$#{organization.id}")
          .of_type([IDP::SamlUnsuccessfulLogin]).first.data[:error_messages]
      end

      context "when saml metadata isn't found" do
        let(:saml_metadatum) { nil }

        it "redirects to error url with error param" do
          post "/saml/#{organization.id}/consume", params: { SAMLResponse: saml_response }

          aggregate_failures do
            expect(response.location).to start_with("https://test.host/login/saml/error")
            expect(Rack::Utils.parse_nested_query(URI(response.location).query)).to eq({ "errors" => ["SAML settings not found"] })
          end
        end
      end

      context "with invalid saml response" do
        let(:one_login) { instance_double("OneLogin::RubySaml::Response", is_valid?: false, errors: ["invalid response"]) }

        it "redirects to error url with error param", :aggregate_failures do
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }

          expect(response.location).to start_with("https://test.host/login/saml/error")
          expect(Rack::Utils.parse_nested_query(URI(response.location).query)).to eq({ "errors" => ["invalid response"] })
        end

        it "publishes event" do
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }

          expect(error_from_event).to eq ["invalid response"]
        end
      end

      context "when organization is not found" do
        it "redirects to error url with error param" do
          post "/saml/123/consume", params: { SAMLResponse: saml_response }

          expect(response.body).to eq("Organization not found")
        end
      end

      context "when email is blank" do
        before do
          allow(one_login).to receive(:name_id).and_return(nil)
        end

        it "does not create a user", :aggregate_failures do
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }

          expect(response.location).to start_with("https://test.host/login/saml/error")
          expect(Rack::Utils.parse_nested_query(URI(response.location).query)).to eq({ "errors" => ["Email can't be blank", "Email is invalid"] })
        end

        it "publishes event" do
          post "/saml/#{organization.id}/consume", params: { id: organization.id, SAMLResponse: saml_response }

          expect(error_from_event).to eq ["Email can't be blank", "Email is invalid"]
        end
      end
    end
  end
end
