# frozen_string_literal: true

module Itineraries
  class LastAvailableDatesController < ApplicationController
    skip_before_action :require_non_guest_authentication!

    def show
      response_handler(lastAvailableDate: last_available_date)
    end

    private

    def last_available_date_params
      params.require(%i(itinerary_ids country))
      params.permit(:itinerary_ids, :country)
    end

    def available_dates
      Itinerary
        .joins(:trips)
        .where(id: last_available_date_params[:itinerary_ids].split(','))
        .distinct
        .order(Trip.arel_table[:closing_date].asc)
        .pluck(Trip.arel_table[:closing_date])
    end

    def last_available_date
      @last_available_date ||= begin
        date = available_dates.last
        return nil if date.nil?

        business_day_counter = 0

        until business_day_counter > buffer
          date -= 1.day
          business_day_counter += 1 if business_day?(date)
        end

        date >= Date.today ? date : nil
      end
    end

    def business_day?(date)
      if Holidays.available_regions.include?(country_code)
        date.on_weekday? && Holidays.on(date, country_code).empty?
      else
        date.on_weekday?
      end
    end

    def country_code
      @country_code ||= country&.code.downcase.to_sym
    end

    def country
      @country ||= begin
        country_param = last_available_date_params[:country]
        Country.where(code: params[:country]).or(Country.where(name: country_param)).first ||
          Country.geo_find_by_name(country_param)
      end
    end

    def buffer
      # TODO: Implement a buffer calculation
      5
    end
  end
end
