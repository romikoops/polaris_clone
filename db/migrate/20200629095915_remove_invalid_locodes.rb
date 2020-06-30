class RemoveInvalidLocodes < ActiveRecord::Migration[5.2]
  def up
    exec_update <<-SQL
      UPDATE hubs SET hub_code = NULL WHERE hub_code !~ '^[A-Z]{2}[A-Z0-9\d]{3}$'
    SQL
    exec_update <<-SQL
      UPDATE nexuses SET locode = NULL WHERE locode !~ '^[A-Z]{2}[A-Z0-9\d]{3}$'
    SQL
  end

  def down
  end
end
