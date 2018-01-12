class MotScope < ApplicationRecord
	has_many :routes

	def self.create_all!
		[true, false].repeated_permutation(6).to_a.each do |values|
		  attributes = MotScope.given_attribute_names.zip(values).to_h
		  MotScope.create!(attributes)
		end
	end

	def self.given_attribute_names
		attribute_names - %w(id created_at updated_at)
	end

	def is_contained_in?(domain_scope)
		MotScope.given_attribute_names.all? { |attribute| 
			domain_scope[attribute] ? true : !self[attribute]  
		}
	end

	def intercepts?(other_scope)
		MotScope.given_attribute_names.any? { |attribute| 
			other_scope[attribute] == self[attribute] && self[attribute] 
		}
	end

	def contained_scopes
		MotScope.all.select { |mot_scope| mot_scope.is_contained_in? self }
	end

	def containing_scopes
		MotScope.all.select { |mot_scope| self.is_contained_in? mot_scope }
	end

	def intercepting_scopes
		MotScope.all.select { |mot_scope| mot_scope.intercepts? self }
	end

	def contained_scope_ids
		contained_scopes.map(&:id)
	end

	def containing_scope_ids
		containing_scopes.map(&:id)
	end

	def intercepting_scope_ids
		intercepting_scopes.map(&:id)
	end
end
