# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record/migration"
require "rails/generators/migration"

class Data
  class MigrationGenerator < Rails::Generators::NamedBase
    include ActiveRecord::Generators::Migration
    source_root File.expand_path("templates", __dir__)

    desc "Generate new asynchronous data migration"

    def create_migration_file
      migration_template "migration.rb.erb", File.join("db/data", "#{file_name}.rb")
      template "worker.rb.erb", File.join("app/workers", class_path, "#{file_name}_worker.rb")
    end

    def create_test_file
      template_file = File.join(
        "spec/workers",
        class_path,
        "#{file_name}_worker_spec.rb"
      )
      template "worker_spec.rb.erb", template_file
    end

    protected

    def migration_base_class_name
      "ActiveRecord::Migration[#{ActiveRecord::Migration.current_version}]"
    end
  end
end
