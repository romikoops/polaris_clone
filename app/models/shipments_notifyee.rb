class ShipmentsNotifyee < ActiveRecord::Base
  belongs_to :shipment
  belongs_to :notifyee
end
