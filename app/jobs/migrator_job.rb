# frozen_string_literal: true

class MigratorJob < ApplicationJob
  queue_as :default
  concurrency 1, drop: false

  def perform
    Migrator.run
  end
end
