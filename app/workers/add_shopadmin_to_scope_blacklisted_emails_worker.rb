class AddShopadminToScopeBlacklistedEmailsWorker
  include Sidekiq::Worker

  def perform(*args)
    default = Organizations::DEFAULT_SCOPE["blacklisted_emails"]

    demo_organizations = Organizations::Organization.where(slug: ["demo", "yourdemo"])

    Organizations::Scope.where.not(target: demo_organizations).find_each do |scope|
      current_list = scope.content["blacklisted_emails"] || []

      merged_list = default | current_list

      scope.content["blacklisted_emails"] = merged_list
      scope.save
    end
  end
end
