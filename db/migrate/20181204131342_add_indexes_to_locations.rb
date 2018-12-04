class AddIndexesToLocations < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      execute "
        create index on locations using gin(to_tsvector('english', postal_code));
        create index on locations using gin(to_tsvector('english', suburb));
        create index on locations using gin(to_tsvector('english', neighbourhood));
        create index on locations using gin(to_tsvector('english', city));
        create index on locations using gin(to_tsvector('english', country));"
    }
  end
end
