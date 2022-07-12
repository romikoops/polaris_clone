# frozen_string_literal: true

module Api
  class Group < Groups::Group
    AVAILABLE_FILTERS = %i[
      sorted_by
      name_search
    ].freeze

    SUPPORTED_SEARCH_OPTIONS = %w[
      name
    ].freeze

    SUPPORTED_SORT_OPTIONS = %w[
      name
    ].freeze

    DEFAULT_FILTER_PARAMS = { sorted_by: "name_asc" }.freeze

    filterrific(
      default_filter_params: DEFAULT_FILTER_PARAMS,
      available_filters: Api::Group::AVAILABLE_FILTERS
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^name/
        order(sanitize_sql_for_order("groups_groups.name #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_by.inspect}")
      end
    }

    scope :name_search, lambda { |input|
      where("groups_groups.name ILIKE ?", "%#{input}%")
    }
  end
  end

# == Schema Information
#
# Table name: groups_groups
#
#  id               :uuid             not null, primary key
#  deleted_at       :datetime
#  name             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organization_id  :uuid
#  tenants_group_id :uuid
#
# Indexes
#
#  index_groups_groups_on_deleted_at        (deleted_at)
#  index_groups_groups_on_organization_id   (organization_id)
#  index_groups_groups_on_tenants_group_id  (tenants_group_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
