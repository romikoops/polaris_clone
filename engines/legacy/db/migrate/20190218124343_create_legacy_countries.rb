class CreateLegacyCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :legacy_countries, id: :uuid do |t|

      t.timestamps
    end
  end
end
