# frozen_string_literal: true

module Pdf
  class CompanyDecorator < ApplicationDecorator
    decorates_association :address, with: AddressDecorator
    delegate_all
  end
end
