class AssignCompanies < ActiveRecord::Migration[5.2]
  def up
    AssignCompaniesWorker.perform_async
  end
end
