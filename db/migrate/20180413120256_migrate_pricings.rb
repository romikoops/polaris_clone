class MigratePricings < ActiveRecord::Migration[5.1]

  def change

    create_table :pricings do |t|
      t.decimal :wm_rate
      t.datetime :effective_date
      t.datetime :expiration_date
      t.references :tenant, index: true
      t.references :transport_category, index: true
      t.references :user, index: true
      t.references :itinerary, index: true
      t.timestamps
    end

    create_table :pricing_exceptions do |t|
      t.datetime :effective_date
      t.datetime :expiration_date
      t.references :pricing, index: true
      t.references :tenant, index: true
      t.timestamps
    end

    create_table :pricing_details do |t|
      t.decimal :rate
      t.string :rate_basis
      t.decimal :min
      t.decimal :hw_threshold
      t.string :hw_rate_basis
      t.string :shipping_type
      t.jsonb :range, default: []
      t.references :currency, index: true
      t.references :priceable, index: true, polymorphic: true
      t.references :tenant, index: true
      t.timestamps
    end

  end
end
