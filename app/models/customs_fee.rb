# frozen_string_literal: true

class CustomsFee < ApplicationRecord
  has_paper_trail
  belongs_to :hub
  belongs_to :tenant
end
