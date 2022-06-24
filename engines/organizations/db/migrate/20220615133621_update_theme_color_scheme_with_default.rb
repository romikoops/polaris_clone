# frozen_string_literal: true

class UpdateThemeColorSchemeWithDefault < ActiveRecord::Migration[5.2]
  def change
    Organizations::Theme.find_each { |theme| theme.update!(color_scheme: Organizations::DEFAULT_COLOR_SCHEMA) if theme.color_scheme.nil? }
  end
end
