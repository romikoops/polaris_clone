# frozen_string_literal: true

require "rails_helper"

RSpec.describe IDP::SamlDataBuilder, type: :request do
  let(:organization) do
    FactoryBot.create(:organizations_organization,
      domains: [organizations_domain],
      theme: FactoryBot.build(:organizations_theme),
      scope: scope)
  end
  let(:scope) { FactoryBot.build(:organizations_scope, content: scope_content) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:organizations_domain) { FactoryBot.create(:organizations_domain, domain: "test.host", default: true) }
  let(:user_groups) do
    OrganizationManager::GroupsService.new(target: created_user, organization: organization).fetch
  end
  let(:currency) { "USD" }
  let(:email) { "test@itsmycargo.com" }
  let(:created_user) { Users::Client.unscoped.find_by(email: email, organization_id: organization.id) }
  let(:attributes) do
    { "firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "customerID" => ["ABCDE"] }
  end
  let(:scope_content) { { default_currency: currency } }
  let(:saml_attributes) { OneLogin::RubySaml::Attributes.new(attributes) }
  let(:one_login) { instance_double("OneLogin::RubySaml::Response", is_valid?: true) }
  let(:decorated_saml_response) { IDP::SamlResponseDecorator.new(one_login) }
  let(:saml_data_builder) do
    described_class.new(saml_response: decorated_saml_response, organization_id: organization.id)
  end

  before do
    FactoryBot.create(:application, name: "dipper")
    Organizations.current_id = organization.id
    allow(OneLogin::RubySaml::Response).to receive(:new).and_return(one_login)
    allow(one_login).to receive(:name_id).and_return(email)
    allow(one_login).to receive(:attributes).and_return(saml_attributes)
  end

  describe ".perform" do
    context "when the user doesn't exist" do
      before do
        saml_data_builder.perform
      end

      it "creates a new user" do
        expect(created_user).to be_present
      end

      it "creates a Profile object for the user", :aggregate_failures do
        expect(created_user.profile).to be_present
        expect(created_user.profile.first_name).to eq(attributes["firstName"].first)
        expect(created_user.profile.last_name).to eq(attributes["lastName"].first)
        expect(created_user.profile.phone).to eq(attributes["phoneNumber"].first.to_s)
        expect(created_user.profile.external_id).to eq(attributes["customerID"].first)
      end

      it "creates a Settings object for the user", :aggregate_failures do
        expect(created_user.settings).to be_present
        expect(created_user.settings.currency).to eq(currency)
      end

      context "when Org scope does not have default currency defined" do
        let(:scope_content) { {} }

        it "creates a Settings object for the user", :aggregate_failures do
          expect(created_user.settings).to be_present
          expect(created_user.settings.currency).to eq(Organizations::DEFAULT_SCOPE["default_currency"])
        end
      end
    end

    context "with successful login and group param present" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let(:attributes) do
        { "firstName" => ["Test"], "lastName" => ["User"], "phoneNumber" => [123_456_789], "groups" => [group.name] }
      end

      before do
        FactoryBot.create(:users_client, email: email, organization: organization)
        saml_data_builder.perform
      end

      it "attaches the user to a group", :aggregate_failures do
        expect(user_groups).to match_array([group, default_group])
      end
    end

    context "with successful login and group param and existing present" do
      let!(:group) { FactoryBot.create(:groups_group, name: "Test Group", organization: organization) }
      let!(:second_group) { FactoryBot.create(:groups_group, name: "Test Group 2", organization: organization) }
      let(:attributes) do
        {
          "firstName" => ["Test"],
          "lastName" => ["User"],
          "phoneNumber" => [123_456_789],
          "groups" => [group.name, second_group.name]
        }
      end

      before do
        FactoryBot.create(:groups_group, name: "Test Group 3", organization: organization)
        saml_data_builder.perform
      end

      it "attaches the user to the correct groups" do
        expect(user_groups).to match_array([group, second_group, default_group])
      end
    end

    context "with company params" do
      let(:external_id) { "companyid" }
      let!(:country) { FactoryBot.create(:legacy_country, code: "sweet_country") }
      let(:company_membership) do
        Companies::Membership.find_by(client: created_user, company: company)
      end
      let(:company) do
        Companies::Company.find_by(name: saml_attributes[:companyName], organization: organization)
      end
      let(:address_params) do
        { "address_1" => ["add_1"], "address_2" => ["add_2"], "address_3" => ["add_3"],
          "street" => ["street"], "house_number" => ["123"],
          "zip" => ["zip"], "city" => ["sweet_home"], "country" => ["sweet_country"] }
      end
      let(:attributes) do
        { "firstName" => ["Test"],
          "lastName" => ["User"],
          "companyID" => [external_id],
          "companyName" => ["companyname"] }.merge(address_params)
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

      shared_examples_for "Company creation from SAML" do
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

      context "when company is present" do
        before do
          FactoryBot.create(:companies_company,
            external_id: external_id,
            name: saml_attributes[:companyName],
            organization: organization)
          saml_data_builder.perform
        end

        it_behaves_like "Company creation from SAML"
      end

      context "when company is present with nil id" do
        before do
          FactoryBot.create(:companies_company,
            external_id: nil,
            name: "new_company",
            organization: organization)
          saml_data_builder.perform
        end

        it_behaves_like "Company creation from SAML"
      end

      context "when company is not present" do
        let(:attributes) do
          {
            "firstName" => ["Test"], "lastName" => ["User"], "companyID" => [external_id], "companyName" => ["new_company"]
          }.merge(address_params)
        end

        before do
          saml_data_builder.perform
        end

        it_behaves_like "Company creation from SAML"
      end
    end
  end
end
