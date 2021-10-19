# frozen_string_literal: true

class AddUniqueConstraintToLocalCharges < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  set_lock_timeout(1000)
  set_statement_timeout(20_000)

  def up
    safety_assured do
      execute <<-SQL
        ALTER TABLE local_charges
          ADD CONSTRAINT local_charges_uuid
          EXCLUDE USING gist (
            uuid WITH =,
            validity WITH &&
          )
          WHERE (deleted_at IS NULL);
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP CONSTRAINT IF EXISTS local_charges_uuid;
      SQL
    end
  end
end
