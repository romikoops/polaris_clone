module Users
  class Admin < Base
    self.inheritance_column = nil

    validates :email, presence: true, uniqueness: true,
                      format: {with: %r{\A.*@itsmycargo\.com\Z}}
  end
end

# == Schema Information
#
# Table name: users_admins
#
#  id                         :uuid             not null, primary key
#  crypted_password           :string
#  email                      :string           not null
#  last_activity_at           :datetime
#  last_login_at              :datetime
#  last_login_from_ip_address :string
#  salt                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_users_admins_on_email  (email)
#
