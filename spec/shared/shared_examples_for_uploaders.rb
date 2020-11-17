# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "uploading request async" do
  describe "uploading" do
    let(:uploader_job) { performed_jobs.find { |j| j[:job] == ExcelDataServices::UploaderJob } }
    let(:complete_email_job) { performed_jobs.find { |j| j[:args][0] == "UploadMailer" } }

    it "returns success response" do
      perform_enqueued_jobs do
        perform_request
      end

      expect(response).to have_http_status(:success)
    end

    it "performs the uploading job" do
      perform_enqueued_jobs do
        perform_request
      end

      expect(uploader_job).to be_present
    end

    it "sends a completion email" do
      perform_enqueued_jobs do
        perform_request
      end

      expect(complete_email_job).to be_present
    end
  end
end
