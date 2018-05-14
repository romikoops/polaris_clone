class Geometry < ApplicationRecord
	validates :name_1, :name_2, :name_3, :name_4, presence: true
	validates :name_1, uniqueness: {
		scope: [:name_2, :name_3, :name_4],
		message: -> obj, _ { "is a duplicate for the names: #{obj.names.log_format}" }
	}

	# Class Methods

	def self.cascading_find_by_names(*args)
		case args.length
		when 1
			return cascading_find_by_name(*args)
		when 2
			return cascading_find_by_two_names(*args)
		else
			raise ArgumentError, "wrong number of arguments (#{args.length} for 2)"
		end
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

	private

	def self.cascading_find_by_two_names(raw_name_1, raw_name_2)
		name_1 = raw_name_1.capitalize
		name_2 = raw_name_2.capitalize

		(1..4).to_a.reverse.each do |i|
			(2..4).to_a.reverse.each do |j|
				next if i >= j
				result = where("name_#{i}" => name_1, "name_#{j}" => name_2).first
				return result unless result.nil?
			end
		end

		nil
	end

	def self.cascading_find_by_name(raw_name)
		name = raw_name.capitalize

		(1..4).to_a.reverse.each do |i|
			result = where("name_#{i}" => name).first
			return result unless result.nil?
		end

		nil		
	end
end
