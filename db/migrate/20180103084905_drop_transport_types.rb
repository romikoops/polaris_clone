class DropTransportTypes < ActiveRecord::Migration[5.1]
  def change
	  drop_table :transport_types
  end
end
