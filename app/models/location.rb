# frozen_string_literal: true

class Location < ApplicationRecord
  # validates :postal_code, :city, :province, :country, presence: true
  validates :postal_code, uniqueness: {
    scope:   %i(neighbourhood city province country),
    message: ->(obj, _) { "is a duplicate for the names: #{obj.names.log_format}" }
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

  def self.find_by_coordinates(lat, lng)
    where("
			SELECT ST_Contains(
				locations.bounds::geometry,
				(SELECT ST_Point(:lng, :lat)::geometry)
			)
	  ", lat: lat, lng: lng).first
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
