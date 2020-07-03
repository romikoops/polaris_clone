# frozen_string_literal: true

module Api
  class DashboardService
    UnknownWidget = Class.new(StandardError)
    attr_reader :user, :organization, :widget_name, :start_date, :end_date

    def self.data(user:, organization:, widget_name:, start_date:, end_date:)
      new(user: user, organization: organization, widget_name: widget_name, start_date: start_date, end_date: end_date).data
    end

    def initialize(user:, organization:, widget_name:, start_date:, end_date:)
      @user = user
      @organization = organization
      @widget_name = widget_name
      @start_date = start_date
      @end_date = end_date
    end

    def data
      widget_klass = "Analytics::Dashboard::#{widget_name.camelize}".safe_constantize
      raise UnknownWidget, 'Widget does not exist' if widget_klass.nil?

      widget_klass.data(user: user, organization: organization, start_date: start_date, end_date: end_date)
    end
  end
end
