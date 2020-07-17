require "rails_helper"

RSpec.describe TruckingMigrationJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  describe "#perform_later" do
    it "enqueues the job" do
      expect {
        TruckingMigrationJob.perform_later(organization_id: SecureRandom.uuid)
      }.to have_enqueued_job
    end
  end
end
