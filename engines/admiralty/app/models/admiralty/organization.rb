# frozen_string_literal: true

module Admiralty
  class Organization < Organizations::Organization
    has_many :charge_categories, -> { where code: %w[trucking_pre export cargo import trucking_on] }, class_name: "Legacy::ChargeCategory"
    accepts_nested_attributes_for :charge_categories

    after_initialize :initialize_charge_categories

    def initialize_charge_categories
      return unless charge_categories.empty?

      %w[trucking_pre export cargo import trucking_on].each do |section|
        charge_categories << Legacy::ChargeCategory.new(code: section, name: section.humanize)
      end
    end
  end
end

# == Schema Information
#
# Table name: organizations_organizations
#
#  id         :uuid             not null, primary key
#  live       :boolean          default(FALSE)
#  slug       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_organizations_organizations_on_slug  (slug) UNIQUE
#
