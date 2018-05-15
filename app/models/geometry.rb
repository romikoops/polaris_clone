class Geometry < ApplicationRecord
	validates :name_1, :name_2, :name_3, :name_4, presence: true
	validates :name_1, uniqueness: {
		scope: [:name_2, :name_3, :name_4],
		message: -> obj, _ { "is a duplicate for the names: #{obj.names.log_format}" }
	}

	# Class Methods

	def self.cascading_find_by_name(raw_name)
		name = raw_name.capitalize

		(1..4).to_a.reverse.each do |i|
			result = where("name_#{i}" => name).first
			return result unless result.nil?
		end

		nil
	end


	# Instance Methods

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

		results["contains"]
	end
end
