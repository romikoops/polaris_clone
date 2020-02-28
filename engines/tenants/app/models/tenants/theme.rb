# frozen_string_literal: true

module Tenants
  class Theme < ApplicationRecord
    belongs_to :tenant, class_name: 'Tenants::Tenant'
    has_one_attached :background
    has_one_attached :small_logo
    has_one_attached :large_logo
    has_one_attached :email_logo
    has_one_attached :white_logo
    has_one_attached :wide_logo
    has_one_attached :booking_process_image
    has_one_attached :welcome_email_image

    validates :tenant_id, uniqueness: true
  end
end

# == Schema Information
#
# Table name: tenants_themes
#
#  id                     :uuid             not null, primary key
#  bright_primary_color   :string
#  bright_secondary_color :string
#  primary_color          :string
#  secondary_color        :string
#  welcome_text           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  tenant_id              :uuid
#
# Indexes
#
#  index_tenants_themes_on_tenant_id  (tenant_id)
#
