# frozen_string_literal: true

module ExcelDataServices
  module DataValidators
    module InsertableChecks
      class DateOverlapChecker < ExcelDataServices::DataValidators::InsertableChecks::Base
        PERFORMING_METHODS = %i(
          no_old_record?
          no_overlap?
          new_starts_before_or_at_old_and_stops_before_old_ends?
          new_starts_after_old_and_stops_at_or_after_old?
          new_is_covered_by_old?
          old_is_covered_by_new?
        ).freeze

        def initialize(old_obj, new_obj)
          @old_obj = old_obj
          @new_obj = new_obj
        end

        def perform
          checker_that_hits = PERFORMING_METHODS.detect { |method_sym| public_send(method_sym) }
          checker_that_hits.to_s.delete('?')
        end

        def no_old_record?
          old_obj.nil? && !new_obj.nil?
        end

        def no_overlap?
          old_expiration_date < new_effective_date || new_expiration_date < old_effective_date
        end

        def new_starts_before_or_at_old_and_stops_before_old_ends?
          new_effective_date <= old_effective_date && new_expiration_date < old_expiration_date
        end

        def new_starts_after_old_and_stops_at_or_after_old?
          new_effective_date > old_effective_date && new_expiration_date >= old_expiration_date
        end

        def new_is_covered_by_old?
          new_effective_date > old_effective_date && new_expiration_date < old_expiration_date
        end

        def old_is_covered_by_new?
          new_effective_date <= old_effective_date && new_expiration_date >= old_expiration_date
        end

        def old_effective_date
          @old_effective_date ||= old_obj.effective_date
        end

        def new_effective_date
          @new_effective_date ||= new_obj.effective_date
        end

        def old_expiration_date
          @old_expiration_date ||= old_obj.expiration_date
        end

        def new_expiration_date
          @new_expiration_date ||= new_obj.expiration_date
        end

        def old_effective_period
          "#{old_effective_date.strftime(date_format)} - #{old_expiration_date.strftime(date_format)}"
        end

        def new_effective_period
          "#{new_effective_date.strftime(date_format)} - #{new_expiration_date.strftime(date_format)}"
        end

        def date_format
          @date_format ||= '%Y-%m-%d %H:%M'
        end

        private

        attr_reader :old_obj, :new_obj
      end
    end
  end
end
