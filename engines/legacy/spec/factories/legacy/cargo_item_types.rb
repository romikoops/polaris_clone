FactoryBot.define do
  factory :legacy_cargo_item_type, class: 'Legacy::CargoItemType' do
    dimension_x { 101 }
    dimension_y { 121 }
    description { '' }
    area { '' }
    category { 'Pallet' }
  end
end
