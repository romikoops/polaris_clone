class AddNoteToItineraries < ActiveRecord::Migration[5.1]
  def change
    add_column :itineraries, :notes, :string
  end
end
