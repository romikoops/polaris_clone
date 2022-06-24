# frozen_string_literal: true

module Organizations
  class Theme < ApplicationRecord
    extend ColorSchemeSetter
    belongs_to :organization, class_name: "Organizations::Organization"

    has_one_attached :background
    has_one_attached :small_logo
    has_one_attached :large_logo
    has_one_attached :email_logo
    has_one_attached :white_logo
    has_one_attached :wide_logo
    has_one_attached :booking_process_image
    has_one_attached :landing_page_hero
    has_one_attached :landing_page_one
    has_one_attached :landing_page_two
    has_one_attached :landing_page_three

    enum landing_page_variant: {default: "default", quotation_plugin: "quotation_plugin", light: "light"}

    define_setters(*Organizations::DEFAULT_COLOR_SCHEMA.keys)

    def method_missing(meth, *args, &blk)
      method_name = meth.to_s
      if color_scheme.key?(method_name)
        color_scheme.fetch(method_name)
      elsif Organizations::DEFAULT_COLOR_SCHEMA.key?(method_name)
        Organizations::DEFAULT_COLOR_SCHEMA.fetch(method_name)
      else
        super
      end
    end

    def respond_to_missing?(meth, *)
      color_scheme.key?(meth.to_s) || Organizations::DEFAULT_COLOR_SCHEMA.key?(meth.to_s) || super
    end
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
#  color_scheme           :jsonb
#  email_links            :jsonb
#  emails                 :jsonb
#  landing_page_variant   :enum             default("default")
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
