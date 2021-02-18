class BackfillGeocodedAddresses < ActiveRecord::Migration[5.2]
  def up
    ActiveRecord::Migration.exec_update("
      -- quotations with delivery or pickup address that has no geocoded address, nor point

     with bad_addresses as (
      SELECT adds.*
      FROM(
      select addresses.*, hubs.point as hub_point from addresses
      JOIN quotations_quotations ON quotations_quotations.pickup_address_id = addresses.id
      JOIN quotations_tenders ON quotations_quotations.id = quotations_tenders.quotation_id
      JOIN hubs ON hubs.id = quotations_tenders.origin_hub_id
      UNION
      SELECT addresses.*, hubs.point as hub_point
      FROM addresses
      JOIN quotations_quotations ON quotations_quotations.delivery_address_id = addresses.id
      JOIN quotations_tenders ON quotations_quotations.id = quotations_tenders.quotation_id
      JOIN hubs ON hubs.id = quotations_tenders.destination_hub_id
      ) adds
      WHERE adds.point is NULL
      OR  geocoded_address is NULL
      )

      update addresses
      set point = COALESCE(addresses.point, bad_addresses.hub_point),
      geocoded_address = COALESCE(addresses.geocoded_address, CONCAT(bad_addresses.city, ', ', bad_addresses.zip_code))
      from bad_addresses
      where addresses.id = bad_addresses.id
      returning *;
    ")
  end
end
