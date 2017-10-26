class CreateDocuments < ActiveRecord::Migration[5.1]
  def change
    create_table :documents do |t|
    		t.string :url
				t.integer :shipment_id
				t.string :text
				t.string :doc_type
				t.integer :user_id
      t.timestamps
    end
  end
end
