class TruckingDestination < ApplicationRecord
   validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }
end
