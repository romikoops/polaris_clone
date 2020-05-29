# frozen_string_literal: true

# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development? && !ENV.has_key?("ANNOTATE_SKIP_ON_DB_MIGRATE")
  require "annotate"
  task :set_annotation_options do
    model_dir = ["app/models"] + Dir["engines/*/app/models"]
    root_dir = [""] + Dir["engines/*"]

    Annotate.set_defaults(
      "additional_file_patterns" => [],
      "routes" => "true",
      "models" => "true",
      "position_in_routes" => "after",
      "position_in_class" => "after",
      "position_in_test" => "after",
      "position_in_fixture" => "after",
      "position_in_factory" => "after",
      "position_in_serializer" => "after",
      "show_foreign_keys" => "true",
      "show_complete_foreign_keys" => "false",
      "show_indexes" => "true",
      "simple_indexes" => "false",
      "model_dir" => model_dir,
      "root_dir" => root_dir,
      "include_version" => "false",
      "require" => "",
      "exclude_tests" => "true",
      "exclude_fixtures" => "true",
      "exclude_factories" => "true",
      "exclude_serializers" => "true",
      "exclude_scaffolds" => "true",
      "exclude_controllers" => "true",
      "exclude_helpers" => "true",
      "exclude_sti_subclasses" => "false",
      "ignore_model_sub_dir" => "false",
      "ignore_columns" => nil,
      "ignore_routes" => nil,
      "ignore_unknown_models" => "false",
      "hide_limit_column_types" => "integer,bigint,boolean",
      "hide_default_column_types" => "json,jsonb,hstore",
      "skip_on_db_migrate" => "false",
      "format_bare" => "true",
      "format_rdoc" => "false",
      "format_markdown" => "false",
      "sort" => "false",
      "force" => "false",
      "frozen" => "false",
      "classified_sort" => "true",
      "trace" => "false",
      "wrapper_open" => nil,
      "wrapper_close" => nil,
      "with_comment" => "true"
    )
  end

  Annotate.load_tasks

  unless ENV.has_key?("SKIP_ANNOTATE") || ENV.has_key?("ANNOTATE_SKIP_ON_DB_MIGRATE")
    Rake::Task["db:migrate"].enhance do
      Rake::Task["annotate_models"].invoke
    end
  end
end
