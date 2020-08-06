class BackfillBlacklistedEmails < ActiveRecord::Migration[5.2]
  def change
    default = Organizations::DEFAULT_SCOPE["blacklisted_emails"]
    Organizations::Scope.find_each do |scope|
      next if scope.content["blacklisted_emails"].blank?

      merged_list = default | scope.content["blacklisted_emails"]

      scope.content["blacklisted_emails"] = merged_list
      scope.save
    end
  end
end
