# frozen_string_literal: true

namespace :migrator do
  desc "Migrate all data"
  task all: :environment do
    Migrator.run
  end
end
