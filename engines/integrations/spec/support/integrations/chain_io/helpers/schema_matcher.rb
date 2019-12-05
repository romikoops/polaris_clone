# frozen_string_literal: true

RSpec::Matchers.define :match_response_schema do |_schema|
  match do |body|
    schema_directory = File.join(File.dirname(__FILE__), '../schemas')
    schema_path = "#{schema_directory}/shipment.json"

    JSON::Validator.validate!(schema_path.to_s, body, strict: true)
  end
end
