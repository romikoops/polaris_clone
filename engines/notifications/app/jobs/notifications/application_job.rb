# frozen_string_literal: true
module Notifications
  class ApplicationJob < ActiveJob::Base
    # Automatically retry jobs that encountered a deadlock
    # retry_on ActiveRecord::Deadlocked

    # Most jobs are safe to ignore if the underlying records are no longer available
    # discard_on ActiveJob::DeserializationError

    private

    def event_store
      Rails.configuration.event_store
    end
  end
end
