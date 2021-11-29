# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ClientCreationService do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:test_email) { "test@imc.test" }
  let(:client_attributes) do
    {
      email: test_email,
      password: "123456789",
      organization_id: organization.id
    }
  end
  let(:profile_attributes) do
    {
      company_name: company_name,
      first_name: "Test",
      last_name: "Person",
      phone: "01628710344"
    }
  end
  let(:settings_attributes) do
    {
      currency: "EUR"
    }
  end
  let(:country) { FactoryBot.create(:country_de) }
  let(:address_attributes) do
    { street: "Brooktorkai", house_number: "7", city: "Hamburg", postal_code: "22047", country: country.name }
  end
  let(:company_name) { "Person Freight" }
  let(:group) { FactoryBot.create(:groups_group, organization: organization) }
  let(:group_id) { group.id }
  let(:service) do
    described_class.new(
      client_attributes: client_attributes,
      profile_attributes: profile_attributes,
      settings_attributes: settings_attributes,
      address_attributes: address_attributes,
      group_id: group_id
    )
  end
  let!(:company) { FactoryBot.create(:companies_company, organization: organization, name: company_name) }
  let(:client) { service.perform }
  let(:client_address) { Legacy::UserAddress.find_by(user: client) }
  let!(:default_company) { FactoryBot.create(:companies_company, organization: organization, name: "default") }

  describe ".perform" do
    before do
      Organizations.current_id = organization.id
    end

    shared_examples_for "restoring an existing client" do
      it "restores the user and updates the profile and settings with the provided info", :aggregate_failures do
        expect(client).to eq(existing_client)
        expect(client.profile.slice(profile_attributes.keys)).to eq(profile_attributes.stringify_keys)
        expect(client.settings.slice(settings_attributes.keys)).to eq(settings_attributes.stringify_keys)
      end
    end

    it "creates the user properly", :aggregate_failures do
      expect(client).to be_valid
      expect(client.email).to eq(test_email)
      expect(client).to be_a(Users::Client)
    end

    it "creates the profile properly", :aggregate_failures do
      expect(client.profile).to be_valid
      expect(client.profile.first_name).to eq("Test")
      expect(client.profile).to be_a(Users::ClientProfile)
    end

    it "creates the settings properly", :aggregate_failures do
      expect(client.settings).to be_valid
      expect(client.settings.currency).to eq("EUR")
      expect(client.settings).to be_a(Users::ClientSettings)
    end

    it "creates the address properly", :aggregate_failures do
      expect(client_address).to be_valid
      expect(client_address.address.zip_code).to eq(address_attributes[:postal_code])
      expect(client_address).to be_a(Legacy::UserAddress)
    end

    it "attaches the user to the correct group", :aggregate_failures do
      expect(Groups::Membership.find_by(member: client, group: group)).to be_valid
    end

    it "attaches the user to the correct company", :aggregate_failures do
      expect(Companies::Membership.find_by(client: client, company: company)).to be_valid
    end

    context "when the company does not exist for the given company name" do
      let(:company) { FactoryBot.create(:companies_company, organization: organization) }
      let(:company_name) { "non-existent" }

      it "attaches the default company, to the user's company" do
        expect(Companies::Membership.find_by(client: client, company: default_company)).to be_valid
      end
    end

    context "when creating client with email belonging to a soft deleted user" do
      let!(:existing_client) do
        FactoryBot.create(:users_client, email: test_email, organization: organization)
      end

      before do
        existing_client.destroy
      end

      it_behaves_like "restoring an existing client"

      context "when the email provided has mixed case" do
        let(:client_attributes) do
          {
            email: test_email.humanize,
            password: "123456789",
            organization_id: organization.id
          }
        end

        it_behaves_like "restoring an existing client"
      end
    end
  end
end
