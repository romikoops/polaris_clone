# frozen_string_literal: true

module Profiles
  class ProfileDecorator < SimpleDelegator
    def full_name
      "#{first_name} #{last_name}"
    end

    def full_name_and_company
      "#{full_name}, #{company_name}"
    end

    def email
      user&.email || ""
    end
  end
end
