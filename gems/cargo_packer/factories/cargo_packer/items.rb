# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_packer_items, class: "Array" do
    data { [] }
    initialize_with do
      data
    end

    trait :case1 do
      data do
        [
          {
            quantity: 1.00,
            length: 1.90,
            width: 0.90,
            height: 1.30,
            stackable: true,
            weight: 100
          },
          {
            quantity: 1.00,
            length: 1.70,
            width: 0.90,
            height: 1.20,
            stackable: true,
            weight: 100
          },
          {
            quantity: 6.00,
            length: 2.05,
            width: 0.80,
            height: 1.60,
            stackable: true,
            weight: 100
          }
        ]
      end
    end

    trait :case2 do
      data do
        [
          {
            quantity: 4.00,
            length: 1.20,
            width: 0.80,
            height: 1.50,
            stackable: true,
            weight: 100
          },
          {
            quantity: 3.00,
            length: 1.20,
            width: 0.80,
            height: 1.20,
            stackable: true,
            weight: 100
          }
        ]
      end
    end

    trait :case3 do
      data do
        [
          {
            quantity: 1.00,
            length: 1.20,
            width: 0.80,
            height: 2.20,
            stackable: false,
            weight: 100
          }
        ]
      end
    end

    trait :case4 do
      data do
        [
          {
            quantity: 2.00,
            length: 1.90,
            width: 0.80,
            height: 0.80,
            stackable: true,
            weight: 100
          },
          {
            quantity: 3.00,
            length: 1.70,
            width: 0.80,
            height: 1.20,
            stackable: true,
            weight: 100
          },
          {
            quantity: 4.00,
            length: 2.05,
            width: 0.80,
            height: 1.30,
            stackable: true,
            weight: 100
          }
        ]
      end
    end
  end
end
