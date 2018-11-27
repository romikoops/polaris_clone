# frozen_string_literal: true

class Port < ApplicationRecord
  belongs_to :nexus
  belongs_to :address
  belongs_to :country
end
