# frozen_string_literal: true

module Api
  class GroupsMembership < Groups::Membership
    AVAILABLE_FILTERS = %i[
      sorted_by
      name_search
    ].freeze

    SUPPORTED_SEARCH_OPTIONS = %w[
      name
    ].freeze

    SUPPORTED_SORT_OPTIONS = %w[
      name
      priority
    ].freeze

    DEFAULT_FILTER_PARAMS = { sorted_by: "priority_asc" }.freeze

    filterrific(
      default_filter_params: DEFAULT_FILTER_PARAMS,
      available_filters: Api::Group::AVAILABLE_FILTERS
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^name/
        unscoped.joins(:group).order(sanitize_sql_for_order("groups_groups.name #{direction}"))
      when /^priority/
        unscoped.order(sanitize_sql_for_order("groups_memberships.priority #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_by.inspect}")
      end
    }

    scope :name_search, lambda { |input|
      joins(:group).where("groups_groups.name ILIKE ?", "%#{input}%")
    }

    # TODO : fix the scope to return all groups recursively
    scope :from_company, lambda { |company_id|
      joins("LEFT OUTER JOIN groups_memberships as gm ON gm.member_id = groups_memberships.group_id")
        .where("groups_memberships.member_id = (?)", company_id)
    }
  end
end

# == Schema Information
#
# Table name: groups_memberships
#
#  id          :uuid             not null, primary key
#  deleted_at  :datetime
#  member_type :string
#  priority    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#
# Indexes
#
#  index_groups_memberships_on_deleted_at                 (deleted_at)
#  index_groups_memberships_on_group_id                   (group_id)
#  index_groups_memberships_on_member_type_and_member_id  (member_type,member_id)
#
# Foreign Keys
#
#  fk_rails_...  (group_id => groups_groups.id)
#
