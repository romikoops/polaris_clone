# frozen_string_literal: true

module Legacy
  class Remark < ApplicationRecord
    self.table_name = 'remarks'

    belongs_to :tenant
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  end
end
