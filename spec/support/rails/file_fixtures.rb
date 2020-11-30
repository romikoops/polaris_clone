# frozen_string_literal: true

module ActiveSupport
  module Testing
    module FileFixtures
      def file_fixture(fixture_name)
        Array(file_fixture_path).each do |fixtures_path|
          path = Pathname.new(File.join(fixtures_path, fixture_name))

          return path if path.exist?
        end

        msg = "the directory '%s' does not contain a file named '%s'"
        raise ArgumentError, msg % [file_fixture_path, fixture_name]
      end
    end
  end
end
