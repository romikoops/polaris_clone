# frozen_string_literal: true

class AddIndexesToLocations < ActiveRecord::Migration[5.2]
  def up
    safety_assured do
      execute "
        create index on locations using gin(to_tsvector('english', postal_code));
        create index on locations using gin(to_tsvector('english', suburb));
        create index on locations using gin(to_tsvector('english', neighbourhood));
        create index on locations using gin(to_tsvector('english', city));
        create index on locations using gin(to_tsvector('english', country));"
    end
  end
end
