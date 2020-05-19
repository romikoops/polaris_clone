# frozen_string_literal: true

# changes the name of legal links to imprint
class BackfillImprintLinks < ActiveRecord::Migration[5.2]
  def change
    exec_update <<~SQL
      UPDATE tenants_scopes
      SET content = jsonb_set(content #- '{links,legal}', '{links,imprint}', content#>'{links,legal}')
      WHERE content#>'{links}' ? 'legal'
    SQL
  end
end
