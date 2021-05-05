# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::UploadPipelines::Okargo, type: :service do
  subject(:pipeline) { described_class.new(organization_id: organization_id, file_wrapper: file_wrapper) }

  let(:organization_id) { FactoryBot.build(:organizations_organization).id }
  let(:client) { Aws::S3::Client.new(stub_responses: true) }
  let(:file_wrapper) { FactoryBot.build(:api_file_wrapper) }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
  end

  describe "#perform" do
    describe "S3 Upload" do
      context "when upload is successful" do
        before do
          allow(Api::AirflowDagRunJob).to receive(:perform_later)
        end

        it "returns true" do
          expect { pipeline.perform }.not_to raise_error
        end
      end

      describe "when etag is not present" do
        before do
          client.stub_responses(
            :put_object, ->(_) { { etag: nil } }
          )
        end

        it "renders error" do
          expect { pipeline.perform }.to raise_error(Aws::S3::Errors::ServiceError)
        end
      end
    end

    describe "Airflow Job" do
      before do
        allow(client).to receive(:put_object).and_return(instance_double("response", etag: true))
      end

      let(:payload) { { conf: { organization_id: organization_id, s3_key: s3_key } }.to_json }
      let(:s3_key) { "#{organization_id}/#{file_wrapper.filename}" }
      let(:dag_name) { "ingest_okargo_v1" }

      it "triggers an Airflow DAGRun job with the correct dag name" do
        ActiveJob::Base.queue_adapter = :test

        expect { pipeline.perform }.to have_enqueued_job.with(dag_name: dag_name, payload: payload).on_queue("default")
      end
    end
  end
end
