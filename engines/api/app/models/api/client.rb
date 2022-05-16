# frozen_string_literal: true

module Api
  class Client < ::Users::Client
    self.inheritance_column = nil

    AVAILABLE_FILTERS = %i[
      sorted_by
      email_search
      first_name_search
      last_name_search
      phone_search
      activity_search
    ].freeze

    SUPPORTED_SEARCH_OPTIONS = %w[
      email
      first_name
      last_name
      phone
      activity
    ].freeze

    SUPPORTED_SORT_OPTIONS = %w[
      created_at
      email
      first_name
      last_name
      phone
      activity
    ].freeze

    DEFAULT_FILTER_PARAMS = { sorted_by: "email_asc" }.freeze

    has_one :membership, class_name: "Companies::Membership"
    has_one :company, through: :membership, class_name: "Companies::Company"

    filterrific(
      default_filter_params: DEFAULT_FILTER_PARAMS,
      available_filters: AVAILABLE_FILTERS
    )

    scope :sorted_by, lambda { |sort_option|
      direction = /desc$/.match?(sort_option) ? "desc" : "asc"
      case sort_option.to_s
      when /^email/
        order(sanitize_sql_for_order("email #{direction}"))
      when /^company_name/
        joins("INNER JOIN companies_memberships ON users_clients.id = companies_memberships.client_id
               INNER JOIN companies_companies ON companies_companies.id = companies_memberships.company_id")
          .order(sanitize_sql_for_order("name #{direction}"))
      when /^first_name/
        sort_by_profile_atributes("first_name", direction)
      when /^last_name/
        sort_by_profile_atributes("last_name", direction)
      when /^phone/
        sort_by_profile_atributes("phone", direction)
      when /^activity/
        order(sanitize_sql_for_order("last_activity_at #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
      end
    }

    scope :sort_by_profile_atributes, lambda { |sort_by, direction|
      joins("INNER JOIN users_client_profiles ON users_clients.id = users_client_profiles.user_id")
        .order(sanitize_sql_for_order("#{sort_by} #{direction}"))
    }

    scope :from_company, lambda { |company_id|
      joins(:membership).where(companies_memberships: { company_id: company_id })
    }

    scope :email_search, lambda { |email|
      where("users_clients.email ILIKE ?", "%#{email}%")
    }

    scope :last_name_search, lambda { |last_name|
      joins("INNER JOIN users_client_profiles ON users_clients.id = users_client_profiles.user_id")
        .where("users_client_profiles.last_name ILIKE ?", "%#{last_name}%")
    }

    scope :phone_search, lambda { |phone|
      joins("INNER JOIN users_client_profiles ON users_clients.id = users_client_profiles.user_id")
        .where("users_client_profiles.phone ILIKE ?", "%#{phone}%")
    }

    scope :first_name_search, lambda { |first_name|
      joins("INNER JOIN users_client_profiles ON users_clients.id = users_client_profiles.user_id")
        .where("users_client_profiles.first_name ILIKE ?", "%#{first_name}%")
    }

    scope :activity_search, lambda { |range|
      where(last_activity_at: range).distinct
    }

    def profile
      super || Users::ClientProfile.new(first_name: "", last_name: "", user: self)
    end

    def settings
      super || Users::ClientSettings.new(
        currency: organization_currency,
        user: self
      )
    end
  end
end

# == Schema Information
#
# Table name: users_clients
#
#  id                                  :uuid             not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  activation_state                    :string
#  activation_token                    :string
#  activation_token_expires_at         :datetime
#  crypted_password                    :string
#  deleted_at                          :datetime
#  email                               :string           not null
#  failed_logins_count                 :integer          default(0)
#  last_activity_at                    :datetime
#  last_login_at                       :datetime
#  last_login_from_ip_address          :string
#  last_logout_at                      :datetime
#  lock_expires_at                     :datetime
#  magic_login_email_sent_at           :datetime
#  magic_login_token                   :string
#  magic_login_token_expires_at        :datetime
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  unlock_token                        :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  organization_id                     :uuid
#
# Indexes
#
#  index_users_clients_on_activation_token           (activation_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_email                      (email) WHERE (deleted_at IS NULL)
#  index_users_clients_on_email_and_organization_id  (email,organization_id) UNIQUE
#  index_users_clients_on_magic_login_token          (magic_login_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_organization_id            (organization_id)
#  index_users_clients_on_reset_password_token       (reset_password_token) WHERE (deleted_at IS NULL)
#  index_users_clients_on_unlock_token               (unlock_token) WHERE (deleted_at IS NULL)
#  users_clients_activity                            (last_logout_at,last_activity_at) WHERE (deleted_at IS NULL)
#
