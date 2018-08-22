# frozen_string_literal: true

RSpec::Matchers.define :match_json_schema do |schema|
  match do |hash|
    schema_directory = "#{Dir.pwd}/spec/support/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"
    JSON::Validator.validate!(schema_path, hash, strict: true)
  end
end
