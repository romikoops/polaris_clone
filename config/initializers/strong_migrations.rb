# frozen_string_literal: true

# Only enforce Strong Migrations for new migrations
StrongMigrations.start_after = 20180913232620 # rubocop:disable Style/NumericLiterals

# Only dump the schema when adding a new migration
ActiveRecord::Base.dump_schema_after_migration =
  Rails.env.development? && `git status db/migrate/ --porcelain`.present?
