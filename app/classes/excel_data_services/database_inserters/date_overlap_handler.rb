# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class DateOverlapHandler < Base
      def initialize(old_objs, new_obj)
        @old_objs = old_objs.empty? ? [nil] : old_objs
        @new_obj = new_obj
        @overlap_checker = nil
      end

      def perform
        objs_with_actions = {}
        @old_objs.each do |old_obj|
          @old_obj = old_obj
          @overlap_checker =
            ExcelDataServices::DataValidators::InsertableChecks::DateOverlapChecker.new(old_obj, new_obj)
          checker_that_hits = overlap_checker.perform
          partial_objs_with_actions = send("handle_#{checker_that_hits}")
          merge_objs_with_actions!(objs_with_actions, partial_objs_with_actions)
        end

        objs_with_actions
      end

      private

      attr_reader :old_obj, :new_obj, :overlap_checker

      def handle_no_old_record
        { should_save: [new_obj] }
      end

      def handle_no_overlap
        { should_save: [new_obj] }
      end

      def handle_new_starts_before_or_at_old_and_stops_before_old_ends
        old_obj.effective_date = (overlap_checker.new_expiration_date + 1.day).beginning_of_day
        { should_save: [old_obj, new_obj] }
      end

      def handle_new_starts_after_old_and_stops_at_or_after_old
        old_obj.expiration_date = (overlap_checker.new_effective_date - 1.day).end_of_day.change(usec: 0)
        { should_save: [old_obj, new_obj] }
      end

      def handle_new_is_covered_by_old
        after_new_obj = old_obj.dup
        after_new_obj.uuid = nil
        old_obj.expiration_date = (overlap_checker.new_effective_date - 1.day).end_of_day.change(usec: 0)
        after_new_obj.effective_date = (overlap_checker.new_expiration_date + 1.day).beginning_of_day
        { should_save: [old_obj, new_obj, after_new_obj] }
      end

      def handle_old_is_covered_by_new
        { should_destroy: [old_obj], should_save: [new_obj] }
      end

      def merge_objs_with_actions!(full, partial)
        # Merges the unique sets of value arrays
        full.merge!(partial) { |_key, old_arr, new_arr| old_arr | new_arr }
      end
    end
  end
end
