export const firstCargoItem = {
  cargo_item_type_id: 'foo',
  chargeable_weight: 250,
  dangerous_goods: false,
  description: 'FOO_CARGO_ITEM_DESCRIPTION',
  dimension_x: 10,
  dimension_y: 60,
  dimension_z: 40,
  gross_weight: 76,
  hs_codes: [4],
  hs_text: 'FOO_CARGO_ITEM_HS_TEXT',
  id: 1,
  key: 'FOO_CARGO_ITEM_KEY',
  payload_in_kg: 200,
  quantity: 5,
  size_class: 'FOO_CARGO_ITEM_SIZE_CLASS',
  stackable: false,
  tare_weight: 20,
  weight: 220
}

export const secondCargoItem = {
  cargo_item_type_id: 'bar',
  chargeable_weight: 150,
  description: 'BAR_CARGO_ITEM_DESCRIPTION',
  dimension_x: 100,
  dimension_y: 50,
  dimension_z: 70,
  hs_codes: [],
  hs_text: 'BAR_CARGO_ITEM_HS_TEXT',
  id: 2,
  key: 'BAR_CARGO_ITEM_KEY',
  payload_in_kg: 100,
  quantity: 7,
  size_class: 'BAR_CARGO_ITEM_SIZE_CLASS',
  stackable: false,
  tare_weight: 17,
  weight: 140
}

export const cargoItems = [firstCargoItem, secondCargoItem]
export const cargoItemTypes = { foo: 'FOO_TYPE', bar: 'BAR_TYPE' }
