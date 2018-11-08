# frozen_string_literal: true

class Location < ApplicationRecord
  # validates :postal_code, :city, :province, :country, presence: true
  validates :postal_code, uniqueness: {
    scope:   %i(neighbourhood city province country),
    message: ->(obj, _) { "is a duplicate for the names: #{obj.names.log_format}" }
  }
  filterrific(
    default_filter_params: { search_locations: '' },
    available_filters: %i(
      search_locations
    )
  )

  scope :search_locations, lambda { |query|
    where(
      'postal_code ILIKE ? OR neighbourhood ILIKE ? OR suburb ILIKE ? OR city ILIKE ?',
       "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
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
    names.compact.join(', ')
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

  # def self.within(lat:, lng:, distance: 0.25)
  #   # TODO: implement using ST_DWithin, and benchmark against this implementation

  #   where(
  #     Arel::Nodes::InfixOperation.new(
  #       '<',
  #       arel_table[:bounds].st_distance("POINT(#{lng} #{lat})"),
  #       Arel::Nodes.build_quoted(distance)
  #     )
  #   )
  # end

  # def self.order_distance(lat:, lng:)
  #   order(arel_table[:bounds].st_distance("POINT(#{lng} #{lat})"))
  # end
end
