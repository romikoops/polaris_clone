# frozen_string_literal: true

require 'cgi'
require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'openssl'
require 'base64'

module OfferCalculator
  class GoogleDirections # rubocop:disable Metrics/ClassLength

    # API Doc: https://developers.google.com/maps/documentation/directions/intro
    BASE_URL  = 'https://maps.googleapis.com'
    BASE_PATH = '/maps/api/directions/xml'
    DEFAULT_OPTIONS = {
      key: Settings.google&.api_key,
      language: 'en',
      alternative: 'false',
      mode: 'driving',
      traffic_model: 'pessimistic'
    }.freeze

    attr_reader :status, :doc, :xml, :origin, :destination, :departure_time, :options

    def initialize(origin, destination, departure_time, opts: DEFAULT_OPTIONS)
      @origin = origin
      @destination = destination
      @departure_time = set_departure_time(departure_time)
      @options = opts.merge({ origin: @origin, destination: @destination, departure_time: @departure_time }.compact)
      path = BASE_PATH + '?' + querify(@options)
      @url = BASE_URL + path
      open(@url) { |io| @xml = io.read } # rubocop:disable Security/Open
      @doc = Nokogiri::XML(@xml)
      @status = @doc.css('status').text
    end

    def set_departure_time(departure_time) # rubocop:disable Naming/AccessorMethodName
      if departure_time < Time.now.to_i + 3600
        'now'
      else
        departure_time
      end
    end

    def successful?
      @status == 'OK'
    end

    def geocoded_start_address
      @doc.css('start_address').text if successful?
    end

    def geocoded_end_address
      @doc.css('end_address').text if successful?
    end

    def reverse_geocoded_start_address
      [@doc.css('start_location lat').last.text.to_f, @doc.css('start_location lng').last.text.to_f] if successful?
    end

    def reverse_geocoded_end_address
      [@doc.css('end_location lat').last.text.to_f, @doc.css('end_location lng').last.text.to_f] if successful?
    end

    def distance_in_meters
      @doc.css('distance value').last.text if successful?
    end

    def distance_in_km
      (distance_in_meters.to_f / 1000.00).round(2) if successful?
    end

    def distance_in_km_with_suffix
      "#{distance_in_km} km"
    end

    def distance_in_miles
      (distance_in_km.to_f / 1.609344000000865).round(2) if successful?
    end

    def distance_in_miles_with_suffix
      "#{distance_in_miles} mi"
    end

    def driving_time_in_seconds
      @doc.css('duration value').last.text.to_i if successful?
    end

    def driving_time_in_seconds_for_trucks(seconds)
      # Trucks are slower than normal cars.
      # Trucks have to comply with provisions about resting periods.
      raise OfferCalculator::Calculator::NoDrivingTime if seconds.nil?

      slowness_factor = 1.6
      seconds = (seconds * slowness_factor).round.to_i
      seconds_of_tour_left = seconds

      resting_time = 0
      time_driven_after_last_full_rest = 0

      until seconds_of_tour_left <= 0
        resting_time += 45 * 60 if time_driven_after_last_full_rest == 4.5 * 3600

        if time_driven_after_last_full_rest == 9 * 3600
          resting_time += 11 * 3600
          time_driven_after_last_full_rest = 0
        end

        time_driven_after_last_full_rest += 1800
        seconds_of_tour_left -= 1800
      end

      seconds + resting_time
    end

    private

    def transcribe(location)
      CGI.escape(location)
    end

    def querify(options)
      params = []

      options.each do |k, v|
        params << "#{transcribe(k.to_s)}=#{transcribe(v.to_s)}" unless k == :private_key
      end

      params.join('&')
    end
  end
end
