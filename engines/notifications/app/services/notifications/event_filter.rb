# frozen_string_literal: true

module Notifications
  class EventFilter
    attr_reader :type, :period, :organization

    def initialize(type:, period:, organization:)
      @type = type
      @period = period
      @organization = organization
    end

    def perform
      events.select { |event| period.cover?(event.timestamp) }
    end

    private

    def client
      @client ||= Rails.configuration.event_store
    end

    def stream_name
      @stream_name ||= "Organization$#{organization.id}"
    end

    def events
      @events ||= client.read.stream(stream_name).of_type([type]).to_a
    end
  end
end
