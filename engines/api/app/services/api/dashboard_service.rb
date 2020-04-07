# frozen_string_literal: true

module Api
  class DashboardService
    UnknownWidget = Class.new(StandardError)
    attr_reader :user, :widget_name, :start_date, :end_date

    def self.data(user:, widget_name:, start_date:, end_date:)
      new(user: user, widget_name: widget_name, start_date: start_date, end_date: end_date).data
    end

    def initialize(user:, widget_name:, start_date:, end_date:)
      @user = user
      @tenant = user.tenant
      @widget_name = widget_name
      @start_date = start_date
      @end_date = end_date
    end

    def data
      widget_klass = "Analytics::Dashboard::#{widget_name.camelize}".safe_constantize
      raise UnknownWidget, 'Widget does not exist' if widget_klass.nil?

      widget_klass.data(user: user, start_date: start_date, end_date: end_date)
    end
  end
end
