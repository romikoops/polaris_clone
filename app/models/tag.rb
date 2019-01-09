# frozen_string_literal: true

class Tag < ApplicationRecord
end

# == Schema Information
#
# Table name: tags
#
#  id         :bigint(8)        not null, primary key
#  tag_type   :string
#  name       :string
#  model      :string
#  model_id   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
