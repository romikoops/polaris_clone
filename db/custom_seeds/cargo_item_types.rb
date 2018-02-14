TenantCargoItemType.destroy_all
CargoItemType.destroy_all
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
    { category: 'Carton'},
    { category: 'Crate'},
    { category: 'Roll'},
    { category: 'Pallet'}
];

CargoItemType.create!(cargo_item_types_data)
