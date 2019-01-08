# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: 'User'
end

# == Schema Information
#
# Table name: messages
#
#  id              :bigint(8)        not null, primary key
#  title           :string
#  message         :string
#  conversation_id :integer
#  read            :boolean
#  read_at         :datetime
#  sender_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
