module Legacy
  class Country < ApplicationRecord
    self.table_name = 'countries'
    has_many :addresses, class_name: 'Legacy::Address'
    has_many :nexuses
  end
end
