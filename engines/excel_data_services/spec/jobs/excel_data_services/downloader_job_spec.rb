# frozen_string_literal: true

require "rails_helper"

module ExcelDataServices
  RSpec.describe DownloaderJob, type: :job do
    include ActiveJob::TestHelper

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:downloader_job_perform) do
      described_class.perform_now(
        organization: organization,
        user: user,
        category_identifier: category_identifier,
        file_name: "#{organization.slug}__hubs_#{Time.zone.today.strftime('%d/%m/%Y')}"
      )
    end
    let(:category_identifier) { "hubs" }

    describe "#perform" do
      shared_examples_for "successful download" do
        it "sends email to the user" do
          perform_enqueued_jobs do
            downloader_job_perform
          end
          expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include(user.email)
        end
      end

      context "when writing document succeeds" do
        it_behaves_like "successful download"
      end

      context "when writing document succeeds (trucking version)" do
        let(:category_identifier) { "trucking" }

        it_behaves_like "successful download"
      end

      context "when writing document fails with exception" do
        before do
          file_writer = ExcelDataServices::FileWriters::Base.get("hubs")
          allow(file_writer).to receive(:write_document).and_raise("error")
        end

        it "sends email to ops" do
          perform_enqueued_jobs do
            downloader_job_perform
          end
          expect(ActionMailer::Base.deliveries.map(&:bcc).flatten).to include("ops@itsmycargo.com")
        end
      end
    end
  end
end
