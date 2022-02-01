# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::LocalChargesController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "demo") }
  let(:user) { FactoryBot.create(:users_user) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:target_group) { FactoryBot.create(:groups_group, name: "AAA", organization: organization) }

  before do
    FactoryBot.create(:users_membership, organization: organization, user: user)
    append_token_header
  end

  describe "GET #index" do
    let!(:local_charge_a) do
      FactoryBot.create(:legacy_local_charge,
        group_id: target_group.id,
        hub: FactoryBot.create(:legacy_hub, name: "AAA", organization: organization),
        counterpart_hub: FactoryBot.create(:legacy_hub, name: "AAAA", organization: organization),
        tenant_vehicle: FactoryBot.build(:legacy_tenant_vehicle, name: "AAA", carrier: FactoryBot.build(:carrier, name: "AAA")),
        organization: organization)
    end
    let!(:local_charge_b) do
      FactoryBot.create(:legacy_local_charge,
        group_id: default_group.id,
        hub: FactoryBot.create(:legacy_hub, name: "BBB", organization: organization),
        counterpart_hub: FactoryBot.create(:legacy_hub, name: "BBBB", organization: organization),
        tenant_vehicle: FactoryBot.build(:legacy_tenant_vehicle, name: "BBB", carrier: FactoryBot.build(:carrier, name: "BBB")),
        organization: organization)
    end

    it "returns an http status of success" do
      get :index, params: { organization_id: organization.id }
      expect(response).to have_http_status(:success)
    end

    it "returns the correct data given the params" do
      get :index, params: { organization_id: organization.id, per_page: 10, hub_desc: "true" }

      expect(response_data["localChargeData"].pluck("id")).to match_array([local_charge_a.id, local_charge_b.id])
    end

    shared_examples_for "index searching" do
      it "returns the LocalCharges related the the specified filters" do
        get :index, params: params.merge(organization_id: organization.id, per_page: 10)

        expect(response_data["localChargeData"].pluck("id")).to eq([local_charge_a.id])
      end
    end

    context "when the group is specified" do
      let(:params) { { group_id: target_group.id } }

      it_behaves_like "index searching"
    end

    context "when the hub is specified" do
      let(:params) { { hub_id: local_charge_a.hub_id } }

      it_behaves_like "index searching"
    end

    context "when the service_level search is specified" do
      let(:params) { { service_level: local_charge_a.tenant_vehicle.name[0..4] } }

      it_behaves_like "index searching"
    end

    context "when the carrier search is specified" do
      let(:params) { { carrier: local_charge_a.tenant_vehicle.carrier.name[0..4] } }

      it_behaves_like "index searching"
    end

    context "when the hub search is specified" do
      let(:params) { { hub: local_charge_a.hub.name[0..4] } }

      it_behaves_like "index searching"
    end

    context "when the counterpart_hub search is specified" do
      let(:params) { { counterpart_hub_name: local_charge_a.counterpart_hub.name[0..4] } }

      it_behaves_like "index searching"
    end

    context "when the group search is specified" do
      let(:params) { { group_name: target_group.name[0..4] } }

      it_behaves_like "index searching"
    end

    shared_examples_for "index sorting" do
      it "returns the LocalCharges related the the specified filters" do
        get :index, params: params.merge(organization_id: organization.id, per_page: 10)

        expect(response_data["localChargeData"].pluck("id")).to eq([local_charge_b.id, local_charge_a.id])
      end
    end

    context "when the service_level_desc is specified" do
      let(:params) { { service_level_desc: "true" } }

      it_behaves_like "index sorting"
    end

    context "when the carrier_desc is specified" do
      let(:params) { { carrier_desc: "true" } }

      it_behaves_like "index sorting"
    end

    context "when the hub_desc is specified" do
      let(:params) { { hub_desc: "true" } }

      it_behaves_like "index sorting"
    end

    context "when the counterpart_hub_desc is specified" do
      let(:params) { { counterpart_hub_name_desc: "true" } }

      it_behaves_like "index sorting"
    end

    context "when the group_desc is specified" do
      let(:params) { { group_name_desc: "true" } }

      it_behaves_like "index sorting"
    end
  end

  describe "POST #edit" do
    let(:local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"))
    end
    let(:fees) { { "ABC" => 123 } }

    it "edits the fees correctly" do
      post :edit, params: {
        organization_id: organization.id, id: local_charge.id, data: { id: local_charge.id, fees: fees }
      }

      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(local_charge.reload.fees.values.first.to_i).to eq(fees.values.first)
      end
    end
  end

  describe "POST #upload" do
    let(:perform_request) do
      post :upload, params: {
        "file" => Rack::Test::UploadedFile.new(File.expand_path("../../test_sheets/spec_sheet.xlsx", __dir__)),
        :organization_id => organization.id
      }
    end

    context "with errors" do
      let(:errors_arr) do
        [{ row_no: 1, reason: "A" },
          { row_no: 2, reason: "B" },
          { row_no: 3, reason: "C" },
          { row_no: 4, reason: "D" }]
      end
      let(:error) { { has_errors: true, errors: errors_arr } }

      let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }
      let(:resulted_errors) do
        complete_email_job[:args][3]["result"]["errors"].map { |err| err.except("_aj_symbol_keys") }
      end

      before do
        excel_service = instance_double("ExcelDataServices::Loaders::Uploader")
        allow(ExcelDataServices::Loaders::Uploader).to receive(:new).and_return(excel_service)
        allow(excel_service).to receive(:perform).and_return(error)

        allow(controller).to receive(:current_organization).and_return(organization)
      end

      it_behaves_like "uploading request async"

      it "sends an email with the upload errors" do
        perform_enqueued_jobs do
          perform_request
        end

        expect(resulted_errors).not_to be_empty
      end
    end
  end

  describe "GET #download" do
    let(:hubs) do
      [
        FactoryBot.create(:hub,
          organization: organization,
          name: "Gothenburg",
          hub_type: "ocean",
          nexus: FactoryBot.create(:nexus, name: "Gothenburg")),
        FactoryBot.create(:hub,
          organization: organization,
          name: "Shanghai",
          hub_type: "ocean",
          nexus: FactoryBot.create(:nexus, name: "Shanghai"))
      ]
    end
    let(:organization_vehicle) do
      FactoryBot.create(:tenant_vehicle, organization: organization)
    end

    let(:expected_response) do
      {
        "key" => "local_charges",
        "success_message" => "local_charges sheet will be e-mailed to #{user.email}"
      }
    end

    before do
      FactoryBot.create(
        :legacy_local_charge,
        mode_of_transport: "ocean",
        load_type: "lcl",
        hub: hubs.first,
        organization: organization,
        tenant_vehicle: organization_vehicle,
        counterpart_hub_id: hubs.second,
        direction: "export",
        fees: {
          "DOC" => {
            "key" => "DOC", "max" => nil, "min" => nil, "name" => "Documentation",
            "value" => 20, "currency" => "EUR", "rate_basis" => "PER_BILL"
          }
        },
        dangerous: nil,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"),
        user_id: nil
      )
    end

    it "returns the expected response data" do
      get :download, params: { organization_id: organization.id, options: { mot: nil, group_id: nil } }
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(response_data).to include(expected_response)
      end
    end
  end

  describe "DELETE #destroy" do
    let(:local_charge) do
      FactoryBot.create(:legacy_local_charge,
        organization: organization,
        effective_date: Date.parse("Thu, 24 Jan 2019"),
        expiration_date: Date.parse("Fri, 24 Jan 2020"))
    end

    it "returns an http status of success" do
      delete :destroy, params: { organization_id: organization, id: local_charge.id }
      expect(response).to have_http_status(:success)
    end

    it "removes the local_charge" do
      delete :destroy, params: { organization_id: organization, id: local_charge.id }
      expect(::Legacy::LocalCharge.find_by(id: local_charge.id)).to be(nil)
    end
  end
end
