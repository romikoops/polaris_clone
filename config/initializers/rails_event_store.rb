require "rails_event_store"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::Client.new(
    dispatcher: RubyEventStore::ComposedDispatcher.new(
      RailsEventStore::AfterCommitAsyncDispatcher.new(scheduler: RailsEventStore::ActiveJobScheduler.new),
      RubyEventStore::Dispatcher.new
    )
  )
end
