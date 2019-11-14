# frozen_string_literal: true

module Legacy
  class TransportCategory < ApplicationRecord
    self.table_name = 'transport_categories'
    belongs_to :vehicle, class_name: 'Legacy::Vehicle'

    validates :cargo_class, presence: true
  end
end
