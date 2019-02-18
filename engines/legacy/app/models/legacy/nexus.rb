module Legacy
  class Nexus < ApplicationRecord
    self.table_name = 'nexuses'
    has_many :hubs, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :country, class_name: 'Legacy::Country'
  end
end
