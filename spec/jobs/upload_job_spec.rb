require "rails_helper"

RSpec.describe UploaderJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  let(:document) { FactoryBot.create(:legacy_file) }
  let(:user) { FactoryBot.create(:organizations_user, organization: document.organization) }

  describe "#perform_later" do
    it "enqueues the job" do
      expect {
        UploaderJob.perform_later(document_id: document.id, options: {user_id: user.id})
      }.to have_enqueued_job
    end
  end
end
