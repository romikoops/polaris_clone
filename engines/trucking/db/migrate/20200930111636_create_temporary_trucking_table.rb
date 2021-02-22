# frozen_string_literal: true
class CreateTemporaryTruckingTable < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    safety_assured do
      execute <<-SQL
        CREATE TABLE new_trucking_truckings
        (
            id uuid NOT NULL DEFAULT gen_random_uuid(),
            hub_id integer,
            location_id uuid,
            rate_id uuid,
            created_at timestamp without time zone NOT NULL,
            updated_at timestamp without time zone NOT NULL,
            load_meterage jsonb,
            cbm_ratio integer,
            modifier character varying COLLATE pg_catalog."default",
            tenant_id integer,
            rates jsonb,
            fees jsonb,
            identifier_modifier character varying COLLATE pg_catalog."default",
            load_type character varying COLLATE pg_catalog."default",
            cargo_class character varying COLLATE pg_catalog."default",
            carriage character varying COLLATE pg_catalog."default",
            courier_id uuid,
            truck_type character varying COLLATE pg_catalog."default",
            legacy_user_id integer,
            parent_id uuid,
            group_id uuid,
            sandbox_id uuid,
            metadata jsonb DEFAULT '{}'::jsonb,
            organization_id uuid,
            user_id uuid,
            tenant_vehicle_id integer,
            deleted_at timestamp without time zone,
            validity daterange,
            CONSTRAINT truckings_pkey PRIMARY KEY (id),
            CONSTRAINT fk_rails_299447a288 FOREIGN KEY (user_id)
                REFERENCES users_users (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION,
            CONSTRAINT fk_rails_c9b2b3a658 FOREIGN KEY (organization_id)
                REFERENCES organizations_organizations (id) MATCH SIMPLE
                ON UPDATE NO ACTION
                ON DELETE NO ACTION
        )
        WITH (
            OIDS = FALSE
        );

        CREATE INDEX index_truckings_on_cargo_class
            ON new_trucking_truckings USING btree
            (cargo_class COLLATE pg_catalog."default" ASC NULLS LAST);

        CREATE INDEX index_truckings_on_carriage
            ON new_trucking_truckings USING btree
            (carriage COLLATE pg_catalog."default" ASC NULLS LAST);

        CREATE INDEX index_truckings_on_deleted_at
            ON new_trucking_truckings USING btree
            (deleted_at ASC NULLS LAST);

        CREATE INDEX index_truckings_on_group_id
            ON new_trucking_truckings USING btree
            (group_id ASC NULLS LAST);

        CREATE INDEX index_truckings_on_hub_id
            ON new_trucking_truckings USING btree
            (hub_id ASC NULLS LAST);

        CREATE INDEX index_truckings_on_load_type
            ON new_trucking_truckings USING btree
            (load_type COLLATE pg_catalog."default" ASC NULLS LAST);

        CREATE INDEX index_truckings_on_location_id
            ON new_trucking_truckings USING btree
            (location_id ASC NULLS LAST);

        CREATE INDEX index_truckings_on_organization_id
            ON new_trucking_truckings USING btree
            (organization_id ASC NULLS LAST);

        CREATE INDEX index_truckings_on_tenant_vehicle_id
            ON new_trucking_truckings USING btree
            (tenant_vehicle_id ASC NULLS LAST);

        CREATE INDEX index_truckings_on_validity
            ON new_trucking_truckings USING gist
            (validity);

        ALTER TABLE new_trucking_truckings
          ADD CONSTRAINT trucking_upsert
          EXCLUDE USING gist (
            hub_id WITH =,
            carriage WITH =,
            load_type WITH =,
            cargo_class WITH =,
            location_id WITH =,
            organization_id WITH =,
            truck_type WITH =,
            group_id WITH =,
            tenant_vehicle_id WITH =,
            validity WITH &&
          )
          WHERE (deleted_at IS NULL);
      SQL
    end
  end

  def down
    safety_assured do
      execute <<-SQL
        DROP TABLE IF EXISTS new_trucking_truckings;
      SQL
    end
  end
end
