# frozen_string_literal: true

module UserServices
  class CompanyMembership
    attr_reader :company

    def initialize(company:)
      @company = company
    end

    def add_membership(users:)
      return if users.nil?

      Companies::Membership.where(client_id: users).where.not(company: company).destroy_all
      users.each do |user|
        restorable_membership = Companies::Membership.only_deleted.find_by(company: company, client_id: user)
        if restorable_membership.present?
          restorable_membership.restore
        else
          Companies::Membership.find_or_create_by!(company: company, client_id: user)
        end
      end
    end
  end
end
