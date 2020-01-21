# frozen_string_literal: true

# Only enforce Strong Migrations for new migrations
StrongMigrations.start_after = 20180913232620 # rubocop:disable Style/NumericLiterals

# PostgreSQL Target
StrongMigrations.target_postgresql_version = 9.6
