# frozen_string_literal: true

class UpdateThemeLandingPageVariantWithDefault < ActiveRecord::Migration[5.2]
  def change
    Organizations::Theme.find_each { |theme| theme.update!(landing_page_variant: "default") }
  end
end
