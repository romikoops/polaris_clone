CargoItemType.destroy_all
cargo_item_types = [
    {x: 101.6, y: 121.9, key: '1016 × 1219', label: '101.6cm × 121.9cm Pallet: North America', area: 'North America'},
    {x: 100.0, y: 120.0, key: '1000 × 1200', label: '100.0cm × 120.0cm Pallet: Europe, Asia', area: 'Europe, Asia'},
    {x: 116.5, y: 116.5, key: '1165 × 1165', label: '116.5cm × 116.5cm Pallet: Australia', area: 'Australia'},
    {x: 106.7, y: 106.7, key: '1067 × 1067', label: '106.7cm × 106.7cm Pallet: North America, Europe, Asia', area: 'North America, Europe, Asia'},
    {x: 110.0, y: 110.0, key: '1100 × 1100', label: '110.0cm × 110.0cm Pallet: Asia', area: 'Asia'},
    {x: 80,  y: 120, key: '800 × 1200', label: '80cm × 120cm Pallet: Europe', area: 'Europe'},
    {key: 'Cartons', label: 'Cartons'},
    {key: 'Crates', label: 'Crates'},
    {key: 'Rolls', label: 'Rolls'}
];

cargo_item_types.each do |ct|
  CargoItemType.create!(dimension_x: ct[:x], dimension_y: ct[:y], description: ct[:label], area: ct[:area])
end