# frozen_string_literal: true

module ExcelDataServices
  module Restructurers
    class Notes < ExcelDataServices::Restructurers::Base
      HTML_FLAGS = ["</p>", "</ol>", "</ul>", "</li>", "</i>"].freeze

      def perform
        restructured_data = data[:rows_data].map { |data|
          next if data[:note].blank?

          contains_html?(note: data[:note]) ? restructure_with_html(data: data) : restructure(data: data)
        }

        {"Notes" => restructured_data.compact}
      end

      def contains_html?(note:)
        HTML_FLAGS.any? { |flag| note.include?(flag) }
      end

      def restructure_with_html(data:)
        fragment = Nokogiri::HTML.fragment(data[:note])
        fragment.xpath("@style|.//@style").remove
        fragment.xpath("@class|.//@class").remove
        data[:note] = fragment.to_s
        data[:contains_html] = true
        data
      end

      def restructure(data:)
        data[:contains_html] = false
        data
      end
    end
  end
end
