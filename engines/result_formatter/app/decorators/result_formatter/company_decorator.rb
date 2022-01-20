# frozen_string_literal: true

module ResultFormatter
  class CompanyDecorator < ApplicationDecorator
    decorates_association :address, with: AddressDecorator
    delegate_all

    def branch_id
      @branch_id ||= memberships.where(client: client).pluck(:branch_id).first
    end

    private

    def client
      context[:client]
    end
  end
end
