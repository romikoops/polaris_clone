# frozen_string_literal: true

module ExcelDataServices
  module Inserters
    class DateOverlapHandler < ExcelDataServices::Inserters::Base
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
            ExcelDataServices::Validators::InsertableChecks::DateOverlapChecker.new(old_obj, new_obj)
          checker_that_hits = overlap_checker.perform
          partial_objs_with_actions = send("handle_#{checker_that_hits}")
          merge_objs_with_actions!(objs_with_actions, partial_objs_with_actions)
        end

        objs_with_actions
      end

      private

      attr_reader :old_obj, :new_obj, :overlap_checker

      def handle_no_old_record
        { save: [new_obj] }
      end

      def handle_no_overlap
        { save: [new_obj] }
      end

      def handle_new_starts_before_or_at_old_and_stops_before_old_ends
        old_obj.effective_date = (overlap_checker.new_expiration_date + 1.day).beginning_of_day
        { save: [old_obj, new_obj] }
      end

      def handle_new_starts_after_old_and_stops_at_or_after_old
        old_obj.expiration_date = (overlap_checker.new_effective_date - 1.day).end_of_day.change(usec: 0)
        { save: [old_obj, new_obj] }
      end

      def handle_new_is_covered_by_old
        after_new_obj = special_deep_dup(old_obj)

        old_obj.expiration_date = (overlap_checker.new_effective_date - 1.day).end_of_day.change(usec: 0)
        after_new_obj.effective_date = (overlap_checker.new_expiration_date + 1.day).beginning_of_day

        { save: [old_obj, new_obj, after_new_obj] }
      end

      def handle_old_is_covered_by_new
        { destroy: [old_obj], save: [new_obj] }
      end

      def special_deep_dup(old_obj)
        after_new_obj = old_obj.dup

        case old_obj.class.name
        when "Pricings::Pricing"
          after_new_obj.fees << old_obj.fees.map { |fee| fee.dup.tap { |new_fee| new_fee.upsert_id = nil } }
          after_new_obj.transient_marked_as_old = true
        end

        after_new_obj
      end

      def merge_objs_with_actions!(full, partial)
        # Merges the unique sets of value arrays
        full.merge!(partial) { |_key, old_arr, new_arr| (old_arr | new_arr).sort_by { |record| record.persisted? ? 0 : 1 } }
      end
    end
  end
end
