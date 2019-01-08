# frozen_string_literal: true

class AlternativeName < ApplicationRecord
end

# == Schema Information
#
# Table name: alternative_names
#
#  id         :bigint(8)        not null, primary key
#  model      :string
#  model_id   :string
#  name       :string
#  locale     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
