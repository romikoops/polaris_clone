# frozen_string_literal: true

require "tsort"

module ExcelDataServices
  module V2
    module Files
      class PrerequisiteExtractor
        attr_reader :parent

        def initialize(parent:)
          @parent = parent
        end

        def prerequisites_for_section(section:)
          schema_file = File.read(File.expand_path("./section_data/#{section.underscore}", __dir__))
          schema_file.lines.select { |line| line.starts_with?("prerequisite") }
            .map { |line| line.gsub!("prerequisite", "").delete('"').strip! }
        end

        def dependencies
          prerequisites.each_with_object(TsortableHash.new)
            .each { |prereq, sortable| sortable[prereq] = prerequisites_for_section(section: prereq) }
            .tsort
        end

        def prerequisites
          @prerequisites ||= nested_sections(section: parent).flatten.uniq + [parent]
        end

        def nested_sections(section:)
          prerequisites_for_section(section: section).map do |prereq|
            [prereq] + nested_sections(section: prereq)
          end
        end

        class TsortableHash < Hash
          include TSort

          alias tsort_each_node each_key
          def tsort_each_child(node, &block)
            fetch(node).each(&block)
          end
        end
      end
    end
  end
end
