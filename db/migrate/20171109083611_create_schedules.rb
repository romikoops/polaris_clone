class CreateSchedules < ActiveRecord::Migration[5.1]
  def change
    create_table :schedules do |t|
      t.integer  :route_id
      t.integer  :starthub_id
      t.integer  :endhub_id

      t.string   :mode_of_transport

      t.datetime :etd
      t.datetime :eta

      t.string   :vessel
      t.string   :call_sign
      t.timestamps
    end
  end
end
