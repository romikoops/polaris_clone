class AddShopadminToScopeBlacklistedEmails < ActiveRecord::Migration[5.2]
  def up
    AddShopadminToScopeBlacklistedEmailsWorker.perform_async
  end
end
