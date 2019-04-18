# frozen_string_literal: true

class Geometry < ApplicationRecord
  validates :name_1, :name_2, :name_3, :name_4, presence: true
  validates :name_1, uniqueness: {
    scope: %i(name_2 name_3 name_4),
    message: ->(obj, _) { "is a duplicate for the names: #{obj.names.log_format}" }
  }

  # Class Methods

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

  # Instance Methods

  def self.find_by_coordinates(lat, lng)
    where("
			SELECT ST_Contains(
				geometries.data::geometry,
				(SELECT ST_Point(:lng, :lat)::geometry)
			)
	  ", lat: lat, lng: lng).first
  end

  def names
    [name_1, name_2, name_3, name_4]
  end

  def contains?(lat, lng)
    sanitized_query = sanitize_sql(["
			SELECT ST_Contains(
			  (SELECT data::geometry FROM geometries WHERE id = :id),
				(SELECT ST_Point(:lng, :lat)::geometry)
			) AS contains
	  ", id: id, lat: lat, lng: lng])

    results = ActiveRecord::Base.connection.execute(sanitized_query).first

    results['contains']
  end

  def self.cascading_find_by_two_names(raw_name_1, raw_name_2)
    name_2 = raw_name_2.split.map(&:capitalize).join(' ')
    name_1_test = raw_name_1.try(:split)
    name_1 = name_1_test.nil? ? name_2 : name_1_test.map(&:capitalize).join(' ')

    (1..4).to_a.reverse_each do |i|
      (2..4).to_a.reverse_each do |j|
        next if i >= j

        result = where("name_#{i}" => name_1, "name_#{j}" => name_2).first
        return result unless result.nil?
      end
    end

    nil
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
# Table name: geometries
#
#  id         :bigint(8)        not null, primary key
#  name_1     :string
#  name_2     :string
#  name_3     :string
#  name_4     :string
#  data       :geometry({:srid= geometry, 0
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
