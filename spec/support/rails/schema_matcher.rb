# frozen_string_literal: true

RSpec::Matchers.define :match_response_schema do |expected|
  match do |actual|
    schema_directory = Pathname.new(File.expand_path("../../schemas", __dir__))

    JSON::Validator.validate!(schema_directory.join("#{expected}.json").to_s, actual, strict: true)
  end
end
