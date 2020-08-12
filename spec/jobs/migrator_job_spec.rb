# frozen_string_literal: true

require "rails_helper"
RSpec.describe MigratorJob, type: :job do
  ActiveJob::Base.queue_adapter = :test

  describe "#perform_later" do
    it "enqueues the job" do
      expect { described_class.perform_later }.to have_enqueued_job
    end
  end
end
