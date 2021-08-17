# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CompaniesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:user) {
    FactoryBot.create(:users_client, organization: organization, email: "user@itsmycargo.com")
  }

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "POST #create" do
    let(:params) {
      {
        name: "Test",
        email: "owner@dummy.com",
        vatNumber: "XXX123",
        organization_id: organization.id
      }
    }
    let(:result) { Companies::Company.find_by(params.slice(:name, :email)) }

    context "without addedMembers" do
      it "creates a new Company" do
        post :create, params: params
        aggregate_failures do
          expect(result).to be_present
          expect(result.name).to eq(params[:name])
          expect(result.email).to eq(params[:email])
          expect(result.vat_number).to eq(params[:vatNumber])
        end
      end
    end

    context "with addedMembers" do
      it "creates a new Company" do
        post :create, params: params.merge(addedMembers: [user.id])
        aggregate_failures do
          expect(result).to be_present
          expect(result.name).to eq(params[:name])
          expect(result.email).to eq(params[:email])
          expect(result.vat_number).to eq(params[:vatNumber])
          expect(::Companies::Membership.count).to eq(1)
        end
      end
    end

    context "with address" do
      let(:address_params) {
        {
          address: {
            streetNumber: 1,
            street: "Test"
          }
        }.merge(params)
      }
      let(:company_address) { FactoryBot.create(:gothenburg_address) }

      before { allow(Legacy::Address).to receive(:geocoded_address).and_return(company_address) }

      it "creates a new Company" do
        post :create, params: address_params
        aggregate_failures do
          expect(result).to be_present
          expect(result.name).to eq(params[:name])
          expect(result.email).to eq(params[:email])
          expect(result.vat_number).to eq(params[:vatNumber])
          expect(result.address).to eq(company_address)
        end
      end
    end
  end

  describe "GET #index" do
    before { FactoryBot.create_list(:companies_company, 5, organization: organization) }

    let(:params) { {organization_id: organization.id} }
    let(:results) { json.dig(:data, :companiesData) }

    context "without filters" do
      it "returns all the companies for the organization" do
        get :index, params: params
        aggregate_failures do
          expect(results.length).to eq(5)
          expect(results.pluck(:id)).to eq(Companies::Company.all.ids)
        end
      end
    end

    context "with name filters" do
      let!(:target_company) { FactoryBot.create(:companies_company, organization: organization, name: "TEST1") }
      let!(:second_company) { FactoryBot.create(:companies_company, organization: organization, name: "TEST2") }
      let(:vat_params) { params.merge(name_desc: false, name: "TEST") }

      it "returns all the companies matching the filter" do
        get :index, params: vat_params
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.pluck(:id)).to eq([target_company.id, second_company.id])
        end
      end
    end

    context "with Vat filters" do
      let!(:target_company) {
        FactoryBot.create(:companies_company, organization: organization, vat_number: "BE-ABCDE")
      }
      let!(:second_company) {
        FactoryBot.create(:companies_company, organization: organization, vat_number: "BE-GHIJ")
      }
      let(:vat_params) { params.merge(vat_number_desc: false, vat_number: "BE-") }

      it "returns all the companies matching the filter" do
        get :index, params: vat_params
        aggregate_failures do
          expect(results.length).to eq(2)
          expect(results.pluck(:id)).to eq([target_company.id, second_company.id])
        end
      end
    end

    context "with country sorting" do
      let(:address_a) { FactoryBot.create(:hamburg_address) }
      let!(:target_company) { FactoryBot.create(:companies_company, organization: organization, address: address_a) }
      let(:country_params) { params.merge(country_desc: false) }

      it "returns all the companies matching the filter" do
        get :index, params: country_params
        aggregate_failures do
          expect(results.length).to eq(6)
          expect(results.dig(0, :id)).to eq(target_company.id)
        end
      end
    end

    context "with country filters" do
      let(:address_a) { FactoryBot.create(:hamburg_address) }
      let!(:target_company) { FactoryBot.create(:companies_company, organization: organization, address: address_a) }
      let(:country_params) { params.merge(country_desc: true, country: "de") }

      it "returns all the companies matching the filter" do
        get :index, params: country_params
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.pluck(:id)).to eq([target_company.id])
        end
      end
    end

    context "with address sorting" do
      let(:address_a) { FactoryBot.create(:hamburg_address) }
      let!(:target_company) { FactoryBot.create(:companies_company, organization: organization, address: address_a) }
      let(:address_params) { params.merge(address_desc: false) }

      it "returns all the companies matching the filter" do
        get :index, params: address_params
        aggregate_failures do
          expect(results.length).to eq(6)
          expect(results.dig(0, :id)).to eq(target_company.id)
        end
      end
    end

    context "with address filters" do
      let(:address_a) { FactoryBot.create(:hamburg_address) }
      let!(:target_company) { FactoryBot.create(:companies_company, organization: organization, address: address_a) }
      let(:address_params) { params.merge(address_desc: true, address: "Brook") }

      it "returns all the companies matching the filter" do
        get :index, params: address_params
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.dig(0, :id)).to eq(target_company.id)
        end
      end
    end
  end

  describe "GET #show" do
    before do
      FactoryBot.create_list(:users_client, 5, organization: organization).each do |employee|
        FactoryBot.create(:companies_membership, company: company, client: employee)
      end
    end

    let!(:group) {
      FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
        FactoryBot.create(:groups_membership, member: company, group: tapped_group)
      end
    }
    let!(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:params) { {organization_id: organization.id, id: company.id} }
    let(:results) { json.dig(:data) }

    it "returns all the companies for the organization" do
      get :show, params: params
      aggregate_failures do
        expect(results.dig(:groups, 0, :id)).to eq(group.id)
        expect(results.dig(:data, :id)).to eq(company.id)
        expect(results.dig(:employees).length).to eq(5)
        expect(results.dig(:employees, 0, :first_name)).to be_present
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      FactoryBot.create_list(:users_client, 5, organization: organization).each do |employee|
        FactoryBot.create(:companies_membership, company: company, client: employee)
      end
    end

    let!(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:params) { {organization_id: organization.id, id: company.id} }
    let(:result) { json.dig(:data) }

    it "returns all the companies for the organization" do
      delete :destroy, params: params
      aggregate_failures do
        expect(result).to be_truthy
        expect(Companies::Company.exists?(id: company.id)).to be_falsy
        expect(Companies::Membership.exists?(company: company)).to be_falsy
      end
    end

    context "when company is a member of a group" do
      let(:main_group) { FactoryBot.create(:groups_group) }
      let!(:membership) { FactoryBot.create(:groups_membership, group: main_group, member: company) }

      it "destroys memberships" do
        delete :destroy, params: params

        expect(Groups::Membership.exists?(membership.id)).to eq false
      end
    end
  end

  describe "POST #edit_employees" do
    let!(:user_a) {
      FactoryBot.create(:users_client, organization: organization).tap do |employee|
        FactoryBot.create(:companies_membership, company: company, client: employee)
      end
    }
    let!(:user_b) {
      FactoryBot.create(:users_client, organization: organization).tap do |employee|
        FactoryBot.create(:companies_membership, company: company, client: employee)
      end
    }
    let!(:user_c) { FactoryBot.create(:users_client, organization: organization) }
    let!(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:params) { { organization_id: organization.id, id: company.id, addedMembers: [user_a, user_c].map(&:as_json) } }

    context "when removing one and adding another Membership" do
      it "updates the employees for the Company", :aggregate_failures do
        post :edit_employees, params: params
        expect(Companies::Membership.find_by(company: company, client: user_a)).to be_present
        expect(Companies::Membership.find_by(company: company, client: user_b)).not_to be_present
        expect(Companies::Membership.find_by(company: company, client: user_c)).to be_present
      end
    end

    context "when a soft deleted Membership exists" do
      before { FactoryBot.create(:companies_membership, company: company, client: user_c).tap(&:destroy) }

      it "updates the employees for the Company, restoring the soft deleted Membership", :aggregate_failures do
        post :edit_employees, params: params
        expect(Companies::Membership.find_by(company: company, client: user_a)).to be_present
        expect(Companies::Membership.find_by(company: company, client: user_b)).not_to be_present
        expect(Companies::Membership.find_by(company: company, client: user_c)).to be_present
      end
    end
  end
end
