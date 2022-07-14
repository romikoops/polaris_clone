# frozen_string_literal: true

require "rails"

require "active_storage/cascade"
require "active_record/postgres_enum"
require "activerecord-postgis-adapter"
require "activerecord-safer_migrations"
require "audited"
require "config"
require "data_migrate"
require "paper_trail"
require "pg"
require "rails_event_store"
require "sidekiq"
require "sidekiq-status"
require "skylight"
require "strong_migrations"

require "data/migration_generator"
