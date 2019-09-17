class AddingBookTypeAndTargetToBooks < ActiveRecord::Migration[5.2]
  def change
    safety_assured {
      change_table :rms_data_books do |t|
        t.references :target, polymorphic: true, index: true, type: :uuid
        t.integer :book_type, default: 0, null: false
      end
    }
  end
end
