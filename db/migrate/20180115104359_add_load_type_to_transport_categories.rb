class AddLoadTypeToTransportCategories < ActiveRecord::Migration[5.1]
  def change
    add_column :transport_categories, :load_type, :string
  end
end
