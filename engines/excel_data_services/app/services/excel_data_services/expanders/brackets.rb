# frozen_string_literal: true

module ExcelDataServices
  module Expanders
    class Brackets < ExcelDataServices::Expanders::Base
      def join_arguments
        {"bracket" => "bracket"}
      end

      def expanded_frame
        initial_frame.concat(bracket_frame)
      end

      def bracket_frame
        Rover::DataFrame.new(expanded_brackets)
      end

      def brackets
        frame["bracket"].to_a.uniq
      end

      def expanded_brackets
        brackets.to_a.uniq.map do |bracket|
          bracket_ends(bracket: bracket)
        end
      end

      def bracket_ends(bracket:)
        first, last = bracket.split("-").map { |first_and_last| first_and_last.strip.to_d }

        {
          "max" => last,
          "min" => first,
          "bracket" => bracket
        }
      end

      def frame_structure
        {
          "max" => [],
          "min" => [],
          "bracket" => []
        }
      end
    end
  end
end
