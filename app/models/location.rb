# frozen_string_literal: true

class Location < ApplicationRecord
  has_many :location_names
  include PgSearch

  validates :postal_code, uniqueness: {
    scope: %i(neighbourhood city province country),
    message: ->(obj, _) { "is a duplicate for the names: #{obj.names.log_format}" }
  }

  pg_search_scope :autocomplete,
                  against: %i(postal_code neighbourhood city province country),
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.find_by_coordinates(lat:, lng:)
    where('ST_Contains(bounds, ST_Point(:lng, :lat))', lat: lat, lng: lng).first
  end

  def contains?(lat:, lng:)
    # TODO: Remove subqueries and write specs

    sanitized_query = sanitize_sql(["
			SELECT ST_Contains(
			  (SELECT bounds::geometry FROM locations WHERE id = :id),
				(SELECT ST_Point(:lng, :lat)::geometry)
			) AS contains
	  ", id: id, lat: lat, lng: lng])

    results = ActiveRecord::Base.connection.execute(sanitized_query).first

    results['contains']
  end

  def names
    [postal_code, neighbourhood, city, province, country]
  end

  def description
    [postal_code, city, country].reject(&:blank?).compact.join(', ')
  end

  def geojson
    RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
  end

  def center
    return nil unless bounds.respond_to?(:centroid)

    %i(longitude latitude).zip(bounds.centroid.coordinates).to_h
  rescue StandardError
    nil
  end

  def as_result_json(options = {})
    new_options = options.reverse_merge(
      methods: %i(geojson center description),
      except: %i(bounds)
    )
    as_json(new_options)
  end

  def self.find_by_coordinates(lat, lng)
    where("
			SELECT ST_Contains(
				locations.bounds::geometry,
				(SELECT ST_Point(:lng, :lat)::geometry)
			)
	  ", lat: lat, lng: lng).first
  end

  def self.cascading_find_by_names(*args)
    case args.length
    when 1
      cascading_find_by_name(*args)
    when 2
      cascading_find_by_two_names(*args)
    else
      raise ArgumentError, "wrong number of arguments (given #{args.length}, expected 2)"
    end
  end

  def self.cascading_find_by_two_names(raw_name_1, raw_name_2)
    name_2 = raw_name_2.split.map(&:capitalize).join(' ')
    name_1_test = raw_name_1.try(:split)
    name_1 = name_1_test.nil? ? name_2 : name_1_test.map(&:capitalize).join(' ')
    keys = %w(postal_code suburb neighbourhood city province country)
    final_result = nil
    keys.to_a.reverse_each.with_index do |name_i, i|
      results_1 = where(name_i => name_1)

      next if results_1.empty?

      results_1.each do |result|
        sub_keys = keys.slice!(0, keys.length - (i + 1))
        sub_keys.to_a.reverse_each.with_index do |name_j, j|
          sub_results = results_1.where(name_j => name_2)
          next unless sub_keys.reverse[j + 1]

          specific_result = sub_results.where(sub_keys.reverse[j + 1] => name_2).first
          result = specific_result || sub_results.first

          final_result = result unless result.nil?
        end
      end
    end
    return final_result unless final_result.nil?

    keys.to_a.reverse_each.with_index do |name_i, _i|
      final_result = where(name_i => name_2).first

      next if final_result
    end

    final_result
  end

  def self.cascading_find_by_name(raw_name)
    name = raw_name.split.map(&:capitalize).join(' ')

    (1..4).to_a.reverse_each do |i|
      result = where("name_#{i} ILIKE ?", name).first
      return result unless result.nil?
    end

    nil
  end
end

# == Schema Information
#
# Table name: locations
#
#  id            :bigint(8)        not null, primary key
#  postal_code   :string
#  suburb        :string
#  neighbourhood :string
#  city          :string
#  province      :string
#  country       :string
#  admin_level   :string
#  bounds        :geometry({:srid= geometry, 0
#
