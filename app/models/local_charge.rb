# frozen_string_literal: true

class LocalCharge < ApplicationRecord
  belongs_to :hub
  belongs_to :tenant
end
