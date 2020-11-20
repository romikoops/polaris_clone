# frozen_string_literal: true

require "cgi"
require "net/http"
require "open-uri"
require "nokogiri"
require "openssl"
require "base64"

class GoogleDirections
  NoDrivingTime = Class.new(StandardError)

  # API Doc: https://developers.google.com/maps/documentation/directions/intro
  BASE_URL = "https://maps.googleapis.com"
  BASE_PATH = "/maps/api/directions/xml"
  DEFAULT_OPTIONS = {
    key: Settings.google.api_key,
    language: "en",
    alternative: "false",
    mode: "driving",
    traffic_model: "pessimistic"
    # avoid: "tolls|highways|ferries"
  }.freeze

  attr_reader :status, :doc, :xml, :origin, :destination, :departure_time, :options

  def initialize(origin, destination, departure_time, opts: DEFAULT_OPTIONS)
    @origin = origin
    @destination = destination
    @departure_time = set_departure_time(departure_time)
    @options = opts.merge({origin: @origin, destination: @destination, departure_time: @departure_time}.compact)
    path = BASE_PATH + "?" + querify(@options)
    @url = BASE_URL + sign_path(path, @options)
    open(@url) { |io| @xml = io.read }
    @doc = Nokogiri::XML(@xml)
    @status = @doc.css("status").text
  end

  def set_departure_time(departure_time)
    if departure_time < Time.now.to_i + 3600
      "now"
    else
      departure_time
    end
  end

  def url_call
    @url
  end

  def public_url
    url = "http://maps.google.com/maps?saddr=#{transcribe(geocoded_start_address)}"
    url << "&daddr=#{transcribe(geocoded_end_address)}&hl=#{@options[:language]}&ie=UTF8"
    url
  end

  def successful?
    @status == "OK"
  end

  def geocoded_start_address
    @doc.css("start_address").text if successful?
  end

  def geocoded_end_address
    @doc.css("end_address").text if successful?
  end

  def reverse_geocoded_start_address
    [@doc.css("start_location lat").last.text.to_f, @doc.css("start_location lng").last.text.to_f] if successful?
  end

  def reverse_geocoded_end_address
    [@doc.css("end_location lat").last.text.to_f, @doc.css("end_location lng").last.text.to_f] if successful?
  end

  def distance_in_meters
    @doc.css("distance value").last.text if successful?
  end

  def distance_in_km
    (distance_in_meters.to_f / 1000.00).round(2) if successful?
  end

  def distance_in_km_with_suffix
    "#{distance_in_km} km"
  end

  def distance_in_miles
    (distance_in_meters.to_f / 1.609344000000865).round(2) if successful?
  end

  def distance_in_miles_with_suffix
    "#{distance_in_miles} mi"
  end

  def driving_time_in_seconds
    @doc.css("duration value").last.text.to_i if successful?
  end

  def driving_time_in_seconds_for_trucks(seconds)
    # Trucks are slower than normal cars.
    # Trucks have to comply with provisions about resting periods.
    raise GoogleDirections::NoDrivingTime if seconds.nil?

    slowness_factor = 1.6
    seconds = (seconds * slowness_factor).round.to_i
    seconds_of_tour_left = seconds

    resting_time = 0
    time_driven_after_last_full_rest = 0

    until seconds_of_tour_left <= 0
      resting_time += 45 * 60 if time_driven_after_last_full_rest == 4.5.to_d * 3600

      if time_driven_after_last_full_rest == 9 * 3600
        resting_time += 11 * 3600
        time_driven_after_last_full_rest = 0
      end

      time_driven_after_last_full_rest += 1800
      seconds_of_tour_left -= 1800
    end

    seconds + resting_time
  end

  def self.formatted_driving_time(seconds)
    seconds = seconds.to_i
    days = seconds / 86_400
    rest_seconds = seconds % 86_400

    hours = rest_seconds / 3600
    rest_seconds = rest_seconds % 3600

    minutes = rest_seconds / 60
    minutes += 1 if rest_seconds % 60 >= 30

    if minutes == 0
      if days == 0
        if hours == 1
          "About one hour"
        elsif hours > 1
          "About #{hours} hours"
        end
      elsif days == 1
        if hours == 1
          "About one day and one hour"
        elsif hours > 1
          "About one day and #{hours} hours"
        end
      elsif days > 1
        if hours == 1
          "About #{days} days and one hour"
        elsif hours > 1
          "About #{days} days and #{hours} hours"
        end
      end
    elsif minutes > 0 && minutes < 30
      if days == 0
        if hours == 0
          "Less than half an hour"
        elsif hours == 1
          "More than one hour"
        elsif hours > 1
          "More than #{hours} hours"
        end
      elsif days == 1
        if hours == 0
          "One day and less than half an hour"
        elsif hours == 1
          "One day and more than one hour"
        elsif hours > 1
          "One day and more than #{hours} hours"
        end
      elsif days > 1
        if hours == 0
          "#{days} days and less than half an hour"
        elsif hours == 1
          "#{days} days and more than one hour"
        elsif hours > 1
          "#{days} days and more than #{hours} hours"
        end
      end
    elsif minutes >= 30 && minutes < 60
      if days == 0
        if hours == 0
          "More than half an hour"
        elsif hours == 1
          "More than one and a half hours"
        elsif hours > 1
          "More than #{hours}.5 hours"
        end
      elsif days == 1
        if hours == 0
          "One day and more than half an hour"
        elsif hours == 1
          "One day and more than one and a half hours"
        elsif hours > 1
          "One day and more than #{hours}.5 hours"
        end
      elsif days > 1
        if hours == 0
          "#{days} days and more than half an hour"
        elsif hours == 1
          "#{days} days and more than one and a half hours"
        elsif hours > 1
          "#{days} days and more than #{hours}.5 hours"
        end
      end
    end
  end

  def steps
    @doc.css("html_instructions").map(&:text) if successful?
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

    params.join("&")
  end

  def sign_path(path, options)
    return path unless options[:private_key]

    raw_private_key = url_safe_base64_decode(options[:private_key])
    digest = OpenSSL::Digest.new("sha1")
    raw_signature = OpenSSL::HMAC.digest(digest, raw_private_key, path)
    path + "&signature=#{url_safe_base64_encode(raw_signature)}"
  end

  def url_safe_base64_decode(base64_string)
    Base64.decode64(base64_string.tr("-_", "+/"))
  end

  def url_safe_base64_encode(raw)
    Base64.encode64(raw).tr("+/", "-_").strip
  end
end
