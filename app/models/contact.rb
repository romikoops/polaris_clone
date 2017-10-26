class Contact < ActiveRecord::Base
  belongs_to :shipper, class_name: "User"
  belongs_to :consignee
  belongs_to :notifyee
end
