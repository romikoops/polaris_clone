class ScheduleSet
  attr_accessor :set
  attr_reader :actual_pickup_date, :departure_date, :eta_terminal

  def initialize(schedules, truck_seconds_pre_carriage, has_on_carriage)
    @set = schedules
    @actual_pickup_date = determine_actual_pickup_date!(truck_seconds_pre_carriage)
    @departure_date = determine_departure_date!
    @eta_terminal = determine_eta_terminal!(has_on_carriage)
  end

  private

  def determine_actual_pickup_date!(truck_seconds_pre_carriage)
    @actual_pickup_date = @set.first.get_pickup_date(truck_seconds_pre_carriage)
  end

  def determine_departure_date!
    @departure_date = @set.first.departure_date
  end

  def determine_eta_terminal!(has_on_carriage)
    schedule = has_on_carriage ? @set[-2] : @set[-1]
    @eta_terminal = schedule.eta
  end
end