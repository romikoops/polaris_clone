# frozen_string_literal: true

puts 'Seeding Cargo Item Types...'
cargo_item_types_data = [
  {
    category: 'Pallet',
    dimension_x: 101.6,
    dimension_y: 121.9,
    area: 'North America'
  },
  {
    category: 'Pallet',
    dimension_x: 100.0,
    dimension_y: 120.0,
    area: 'Europe, Asia'
  },
  {
    category: 'Pallet',
    dimension_x: 116.5,
    dimension_y: 116.5,
    area: 'Australia'
  },
  {
    category: 'Pallet',
    dimension_x: 106.7,
    dimension_y: 106.7,
    area: 'North America, Europe, Asia'
  },
  {
    category: 'Pallet',
    dimension_x: 110.0,
    dimension_y: 110.0,
    area: 'Asia'
  },
  {
    category: 'Pallet',
    dimension_x: 80,
    dimension_y: 120,
    area: 'Europe'
  },
  { category: 'Carton' },
  { category: 'Crate' },
  { category: 'Roll' },
  { category: 'Pallet' },
  { category: 'Bottle' },
  { category: 'Stack' },
  { category: 'Drum' },
  { category: 'Package' },
  { category: 'Skid' },
  { category: 'Barrel' },
  { category: 'Carton (only palletized)' },
  { category: 'Drum (only palletized)' }
]

ATTR_NAMES = %i(dimension_x dimension_y area category).freeze

cargo_item_types_data.each do |raw_cargo_item_types_attr|
  cargo_item_types_attr = ATTR_NAMES.each_with_object({}) do |attr_name, obj|
    obj[attr_name] = raw_cargo_item_types_attr[attr_name]
  end

  cargo_item = CargoItemType.find_or_create_by(cargo_item_types_attr)
end
