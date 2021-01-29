# frozen_string_literal: true

module ResultFormatter
  class CompanyDecorator < ApplicationDecorator
    decorates_association :address, with: AddressDecorator
    delegate_all
  end
end
