export const hsCodes = [
  [{ value: 'HSCODE_VALUE_0', text: 'HSCODE_TEXT_0' }],
  [{ value: 'HSCODE_VALUE_1', text: 'HSCODE_TEXT_1' }],
  [{ value: 'HSCODE_VALUE_2', text: 'HSCODE_TEXT_2' }],
  [{ value: 'HSCODE_VALUE_3', text: 'HSCODE_TEXT_3' }],
  [{ value: 'HSCODE_VALUE_4', text: 'HSCODE_TEXT_4' }],
  [{ value: 'HSCODE_VALUE_5', text: 'HSCODE_TEXT_5' }]
]

export const firstContainer = {
  cargo_group_id: 4,
  customs_text: 'FOO_CONTAINER_CUSTOMS_TEXT',
  gross_weight: 130,
  hs_codes: [],
  id: 1,
  payload_in_kg: 200,
  quantity: 5,
  size_class: 'FOO_CONTAINER_SIZE_CLASS',
  tare_weight: 50
}

export const secondContainer = {
  cargo_group_id: 5,
  customs_text: 'BAR_CONTAINER_CUSTOMS_TEXT',
  gross_weight: 457,
  hs_codes: [],
  id: 2,
  payload_in_kg: 450,
  quantity: 7,
  size_class: 'BAR_CONTAINER_SIZE_CLASS',
  tare_weight: 7
}

export const containers = [firstContainer, secondContainer]
