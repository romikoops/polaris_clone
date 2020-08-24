# frozen_string_literal: true

class BackfillAddWebsitesToOrganizationsTheme < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    Organizations::Theme.unscoped.in_batches do |relation|
      relation.each { |u| u.update(websites: {}) }
    end
  end
end
