# frozen_string_literal: true

module Organizations
  class Theme < ApplicationRecord
    belongs_to :organization, class_name: "Organizations::Organization"

    has_one_attached :background
    has_one_attached :small_logo
    has_one_attached :large_logo
    has_one_attached :email_logo
    has_one_attached :white_logo
    has_one_attached :wide_logo
    has_one_attached :booking_process_image
    has_one_attached :welcome_email_image

  end
end

# == Schema Information
#
# Table name: organizations_themes
#
#  id                     :uuid             not null, primary key
#  addresses              :jsonb
#  bright_primary_color   :string
#  bright_secondary_color :string
#  email_links            :jsonb
#  emails                 :jsonb
#  name                   :string
#  phones                 :jsonb
#  primary_color          :string
#  secondary_color        :string
#  websites               :jsonb
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  organization_id        :uuid
#
# Indexes
#
#  index_organizations_themes_on_organization_id  (organization_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
