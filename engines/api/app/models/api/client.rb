# frozen_string_literal: true

module Api
  class Client < ::Users::Client
    self.inheritance_column = nil

    PROFILE_ATTRIBUTES = ["first_name", "last_name", "phone"]
    filterrific(
      default_filter_params: {sorted_by: "email_asc"},
      available_filters: [
        :sorted_by
      ]
    )

    scope :sorted_by, lambda { |sort_by, direction|
      if sort_by == "email"
        order(sanitize_sql_for_order("email #{direction}"))
      elsif sort_by == "company_name"
        joins("INNER JOIN companies_memberships ON users_clients.id = companies_memberships.client_id
               INNER JOIN companies_companies ON companies_companies.id = companies_memberships.company_id")
          .order(sanitize_sql_for_order("name #{direction}"))
      elsif PROFILE_ATTRIBUTES.include?(sort_by)
        joins("INNER JOIN users_client_profiles ON users_clients.id = users_client_profiles.user_id")
          .order(sanitize_sql_for_order("#{sort_by} #{direction}"))
      else
        raise(ArgumentError, "Invalid sort option: #{sort_by.inspect}")
      end
    }
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
