# frozen_string_literal: true

module CmsData
  class Widget < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"

    validates :name, presence: true
    validates :data, presence: true
    validates :order, presence: true
  end
end

# == Schema Information
#
# Table name: cms_data_widgets
#
#  id              :uuid             not null, primary key
#  data            :string           not null
#  name            :string           not null
#  order           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :uuid
#
# Indexes
#
#  index_organizations_widgets_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
