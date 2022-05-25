# frozen_string_literal: true

module Distributions
  class Execution < ApplicationRecord
    belongs_to :action, class_name: "Distributions::Action"
    validates_presence_of :file_id
  end
end

# == Schema Information
#
# Table name: distributions_executions
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  action_id  :uuid
#  file_id    :uuid             not null
#
# Indexes
#
#  index_distributions_executions_on_action_id  (action_id)
#  index_distributions_executions_on_file_id    (file_id)
#
