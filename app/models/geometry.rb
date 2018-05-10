class Geometry < ApplicationRecord
	validates :name_1, :name_2, :name_3, :name_4, presence: true
	validates :name_1, uniqueness: {
		scope: [:name_2, :name_3, :name_4],
		message: -> obj, _ { "is a duplicate for the names: #{obj.names.join(" | ")}" }
	} 

	def names
		[name_1, name_2, name_3, name_4]
	end
end
