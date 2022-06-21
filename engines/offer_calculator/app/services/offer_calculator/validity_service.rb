# frozen_string_literal: true

module OfferCalculator
  class ValidityService
    START_BUFFER = 5
    END_BUFFER = 25

    def initialize(logic:, schedules:, direction:, booking_date: Date.current)
      @validity_logic = logic
      @schedules = schedules
      @direction = direction
      @booking_date = booking_date
    end

    def parse_schedule(schedule:, direction:)
      @schedules = [schedule]
      @direction = direction
    end

    def parse_direction(direction:)
      @direction = direction
    end

    def start_date
      @start_date ||= start_value
    end

    def end_date
      @end_date ||= end_value
    end

    def period
      Range.new(start_date, end_date, exclude_end: true)
    end

    private

    def start_value
      return default_start_date if schedules.blank?

      case validity_logic
      when "vatos"
        schedules.first.etd.to_date
      when "vatoa"
        method = direction == "export" ? :etd : :eta
        schedules.first.try(method)&.to_date
      when "vatob"
        booking_date.to_date
      else
        default_start_date
      end
    end

    def end_value
      return default_end_date if schedules.empty?

      date = case validity_logic
            when "vatos"
              schedules.last.etd.to_date
            when "vatoa"
              method = direction == "export" ? :etd : :eta
              schedules.last.try(method)&.to_date
            when "vatob"
              booking_date.to_date
            else
              default_end_date
      end
      verify_end_value(date: date)
    end

    def verify_end_value(date:)
      date.to_date == start_value.to_date ? start_value + 1.day : date
    end

    def default_start_date
      START_BUFFER.days.from_now.to_date
    end

    def default_end_date
      END_BUFFER.days.from_now.to_date
    end

    attr_reader :validity_logic, :schedules, :direction, :booking_date
  end
end
