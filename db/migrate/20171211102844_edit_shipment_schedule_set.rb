class EditShipmentScheduleSet < ActiveRecord::Migration[5.1]
  def change
    remove_column :shipments, :schedule_set, :integer, array: true
    add_column :shipments, :schedule_set, :jsonb, array: true, default: []
  end
end
