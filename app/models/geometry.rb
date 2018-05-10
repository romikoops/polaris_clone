class Geometry < ApplicationRecord
	validates :name_1, :name_2, :name_3, :name_4, presence: true
	validates :name_1, uniqueness: {
		scope: [:name_2, :name_3, :name_4],
		message: -> obj, _ { "is a duplicate for the names: #{obj.names.log_format}" }
	}

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
