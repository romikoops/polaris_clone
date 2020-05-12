export const firstCargoItem = {
  cargo_item_type_id: 'foo',
  chargeable_weight: 250,
  dangerous_goods: false,
  description: 'FOO_CARGO_ITEM_DESCRIPTION',
  width: 10,
  length: 60,
  height: 40,
  gross_weight: 76,
  hs_codes: [4],
  hs_text: 'FOO_CARGO_ITEM_HS_TEXT',
  id: 1,
  key: 'FOO_CARGO_ITEM_KEY',
  payload_in_kg: 200,
  quantity: 5,
  stackable: true,
  tare_weight: 20,
  weight: 220
}

export const secondCargoItem = {
  cargo_item_type_id: 'bar',
  chargeable_weight: 150,
  description: 'BAR_CARGO_ITEM_DESCRIPTION',
  width: 100,
  length: 50,
  height: 70,
  hs_codes: [],
  hs_text: 'BAR_CARGO_ITEM_HS_TEXT',
  id: 2,
  key: 'BAR_CARGO_ITEM_KEY',
  payload_in_kg: 100,
  quantity: 7,
  stackable: false
}

export const cargoItems = [firstCargoItem, secondCargoItem]
export const cargoItemTypes = { foo: { description: 'FOO_TYPE' }, bar: { description: 'BAR_TYPE' } }

export const cargoItemGroup = {
  length: parseFloat(firstCargoItem.length) * parseInt(firstCargoItem.quantity, 10),
  height: parseFloat(firstCargoItem.height) * parseInt(firstCargoItem.quantity, 10),
  width: parseFloat(firstCargoItem.width) * parseInt(firstCargoItem.quantity, 10),
  payload_in_kg: parseFloat(firstCargoItem.payload_in_kg) * parseInt(firstCargoItem.quantity, 10),
  quantity: 1,
  groupAlias: 1,
  cargo_group_id: firstCargoItem.id,
  chargeable_weight: parseFloat(firstCargoItem.chargeable_weight) * parseInt(firstCargoItem.quantity, 10),
  hsCodes: firstCargoItem.hs_codes,
  hsText: firstCargoItem.hs_text,
  cargoType: { description: 'FOO_TYPE' },
  volume:
    parseFloat(firstCargoItem.length) *
    parseFloat(firstCargoItem.width) *
    parseFloat(firstCargoItem.height) /
    1000000 *
    parseInt(firstCargoItem.quantity, 10),
  items: [firstCargoItem]
}