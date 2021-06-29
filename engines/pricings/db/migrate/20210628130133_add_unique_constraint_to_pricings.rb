# frozen_string_literal: true

class AddUniqueConstraintToPricings < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  set_lock_timeout(1000)
  set_statement_timeout(15_000)

  def up
    safety_assured do
      execute <<-SQL
        ALTER TABLE pricings_pricings
          ADD CONSTRAINT pricing_upsert
          EXCLUDE USING gist (
            upsert_id WITH =,
            validity WITH &&
          )
          WHERE (deleted_at IS NULL);
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP CONSTRAINT IF EXISTS pricing_upsert;
      SQL
    end
  end
end
