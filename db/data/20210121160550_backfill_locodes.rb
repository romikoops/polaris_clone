class BackfillLocodes < ActiveRecord::Migration[5.2]
  def up
    ## with saco hub data
    saco = Organizations::Organization.find_by(slug: "saco")
    ActiveRecord::Migration.exec_update("
      WITH saco_nexuses as (
        SELECT locode, name, country_id
        FROM nexuses
        WHERE nexuses.organization_id = '#{saco.id}'
        AND nexuses.locode IS NOT NULL
      )

      UPDATE nexuses
      SET locode = saco_nexuses.locode
      FROM saco_nexuses
      WHERE nexuses.name = saco_nexuses.name
      AND nexuses.country_id = saco_nexuses.country_id
      AND nexuses.locode IS NULL
    ")

    ActiveRecord::Migration.exec_update("
      WITH saco_hubs as (
        SELECT hub_code, hubs.name, country_id
        FROM hubs
        JOIN addresses
        ON hubs.address_id = addresses.id
        WHERE hubs.organization_id = '#{saco.id}'
        AND hubs.hub_code IS NOT NULL
      )

      UPDATE hubs
      SET hub_code = saco_hubs.hub_code
      FROM saco_hubs, addresses
      WHERE hubs.address_id = addresses.id
      AND hubs.name = saco_hubs.name
      AND addresses.country_id = saco_hubs.country_id
      AND hubs.hub_code IS NULL
    ")

    ## with other hub data
    ActiveRecord::Migration.exec_update("
      WITH all_nexuses as (
        SELECT locode, name, country_id
        FROM nexuses
        WHERE nexuses.locode IS NOT NULL
      )

      UPDATE nexuses
      SET locode = all_nexuses.locode
      FROM all_nexuses
      WHERE nexuses.name = all_nexuses.name
      AND nexuses.country_id = all_nexuses.country_id
      AND nexuses.locode IS NULL
    ")

    ActiveRecord::Migration.exec_update("
      WITH all_hubs as (
        SELECT hub_code, hubs.name, country_id
        FROM hubs
        JOIN addresses
        ON hubs.address_id = addresses.id
        WHERE hubs.hub_code IS NOT NULL
      )

      UPDATE hubs
      SET hub_code = all_hubs.hub_code
      FROM all_hubs, addresses
      WHERE hubs.address_id = addresses.id
      AND hubs.name = all_hubs.name
      AND addresses.country_id = all_hubs.country_id
      AND hubs.hub_code IS NULL
    ")
  end
end
