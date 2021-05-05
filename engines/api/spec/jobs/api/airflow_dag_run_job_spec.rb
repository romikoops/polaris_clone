# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::AirflowDagRunJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(dag_name: dag_name, payload: payload) }

  after do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  let(:dag_name) { "foo_v1" }
  let(:organization_id) { FactoryBot.build(:organizations_organization).id }
  let(:payload) { { organization_id: organization_id, s3_key: "#{organization_id}/deadbeef.json" }.to_json }
  let(:endpoint) { "/api/v1/dags/#{dag_name}/dagRuns" }
  let(:iam_credentials_client) { instance_double("Google IAM Credentials Client") }
  let(:id_token_response) { instance_double("Google IAM ID Token Response") }
  let(:google_open_id_token) { SecureRandom.uuid }

  before do
    allow(Google::Iam::Credentials::V1::IAMCredentials::Client).to receive(:new).and_return(iam_credentials_client)
    allow(iam_credentials_client).to receive(:generate_id_token)
      .with(
        audience: "itsmycargo-main.apps.googleusercontent.com",
        name: "projects/-/serviceAccounts/polaris@itsmycargo-main.iam.gserviceaccount.com",
        include_email: true
      )
      .and_return(id_token_response)
    allow(id_token_response).to receive(:token).and_return(google_open_id_token)
  end

  it "calls IMC-Airflow's DAGRun API using a Google OpenID token" do
    stub_request(:post, URI.join(Settings.airflow, endpoint))
      .with(body: payload, headers: { "Authorization" => "Bearer #{google_open_id_token}", "Content-Type" => "application/json" })
      .to_return(status: 200, body: "", headers: {})

    perform_enqueued_jobs { job }
  end
end
