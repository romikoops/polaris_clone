class AddContainerToColliTypes < ActiveRecord::Migration[5.2]
  def change
    safety_assured do
      execute <<-SQL
        ALTER TYPE journey_colli_type ADD VALUE 'container'
      SQL
    end
  end
end

