# frozen_string_literal: true

module Tracker
  class Interaction < ApplicationRecord
    validates :name, presence: true, uniqueness: true
  end
end

# == Schema Information
#
# Table name: tracker_interactions
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tracker_interactions_on_name  (name) UNIQUE
#
