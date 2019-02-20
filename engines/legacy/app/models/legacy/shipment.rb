module Legacy
  class Shipment < ApplicationRecord
    self.table_name = 'shipments'
    LOAD_TYPES = %w(cargo_item container).freeze
  end
end
