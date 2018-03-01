class Vehicle < ApplicationRecord
  has_many :transport_categories
  has_many :itineraries

  validates :name,
  	presence: true,
  	uniqueness: {
  		scope: :mode_of_transport,
  		message: -> _self, _ do
  			"'#{_self.name}' taken for mode of transport '#{_self.mode_of_transport}'"
  		end
  	}
end
