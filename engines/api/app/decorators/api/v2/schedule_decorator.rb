# frozen_string_literal: true

module Api
  module V2
    class ScheduleDecorator < Draper::Decorator
      delegate_all
      decorates_association :result, with: ResultDecorator
    end
  end
end
