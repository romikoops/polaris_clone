# frozen_string_literal: true

FactoryBot.define do
  factory :message do
  end
end

# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  title           :string
#  message         :string
#  conversation_id :integer
#  read            :boolean
#  read_at         :datetime
#  sender_id       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
