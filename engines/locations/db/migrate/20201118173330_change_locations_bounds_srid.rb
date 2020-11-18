class ChangeLocationsBoundsSrid < ActiveRecord::Migration[5.2]
  def up
    exec_update <<-SQL
      SELECT UpdateGeometrySRID('locations_locations','bounds',4326);
    SQL
  end

  def down
  end
end
