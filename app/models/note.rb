# frozen_string_literal: true

class Note < Legacy::Note
end

# == Schema Information
#
# Table name: notes
#
#  id                  :bigint           not null, primary key
#  itinerary_id        :integer
#  hub_id              :integer
#  trucking_pricing_id :integer
#  body                :string
#  header              :string
#  level               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  sandbox_id          :uuid
#  target_type         :string
#  target_id           :integer
#  pricings_pricing_id :uuid
#  tenant_id           :integer
#  contains_html       :boolean
#  transshipment       :boolean          default(FALSE), not null
#  remarks             :boolean          default(FALSE), not null
#
