# frozen_string_literal: true

class ValidityService
  attr_reader :start_date, :end_date

  def initialize(logic:, schedules:, direction:, booking_date: Date.current)
    @validity_logic = logic
    @start_date = 5.days.from_now
    @end_date = 25.days.from_now
    @schedules = schedules
    @direction = direction
    @booking_date = booking_date
    parse_schedules
  end

  def parse_schedules
    return [start_date, end_date] if schedules.blank?

    case validity_logic
    when 'vatos'
      handle_vatos_schedules
    when 'vatoa'
      handle_vatoa_schedules
    when 'vatob'
      @start_date = @end_date = booking_date
    end
    @start_date = start_value if start_value.present?
    @end_date = end_value if end_value.present?
  end

  def handle_vatos_schedules
    @start_value = schedules.first.etd
    @end_value = schedules.last.etd
  end

  def handle_vatoa_schedules
    method = direction == 'export' ? :etd : :eta
    @start_value = schedules.first.try(method)
    @end_value = schedules.last.try(method)
  end

  private

  attr_reader :validity_logic, :schedules, :direction, :booking_date, :start_value, :end_value
end
