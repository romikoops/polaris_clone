# frozen_string_literal: true

require "strong_migrations"

# Only enforce Strong Migrations for new migrations
StrongMigrations.start_after = 20180913232620

# PostgreSQL Target
StrongMigrations.target_postgresql_version = "10"
