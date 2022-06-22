# frozen_string_literal: true

module Notifications
  class EventRepublisher
    attr_reader :events

    def initialize(events:)
      @events = events
    end

    def perform
      events_grouped_by_class.each do |event_class, events|
        events.product(jobs(event_class: event_class)).each_with_index do |(event, job), index|
          job.set(wait: index.minutes).perform_later(
            RubyEventStore::Mappers::Default.new.event_to_serialized_record(event).as_json
          )
        end
      end
    end

    private

    def jobs(event_class:)
      Notifications::Events::EVENT_JOBS_LOOKUP[event_class] || []
    end

    def events_grouped_by_class
      @events_grouped_by_class ||= events.group_by(&:class)
    end
  end
end
