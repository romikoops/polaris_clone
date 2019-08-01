module Routing
  class LineService < ApplicationRecord
    belongs_to :carrier, class_name: 'Routing::Carrier'

    enum category: { fastest: 1, standard: 2, cheapest: 3 }

  end
end

# == Schema Information
#
# Table name: routing_line_services
#
#  id         :uuid             not null, primary key
#  name       :string
#  carrier_id :uuid
#  category   :integer          default(NULL), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
