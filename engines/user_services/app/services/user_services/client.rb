# frozen_string_literal: true

module UserServices
  class Client < ::Users::Client
    has_one :company_membership, class_name: "::Companies::Membership", dependent: :destroy
    has_many :group_memberships, class_name: "::Groups::Membership", foreign_key: :member_id, dependent: :destroy
  end
end
