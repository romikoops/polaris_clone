# frozen_string_literal: true

class RemoveDuplicateProfilesForAUserWorker
  include Sidekiq::Worker
  FailedDeduping = Class.new(StandardError)

  def perform
    user_profile_hash = Users::Profile.where(user: duplicate_profile_user_ids).order(updated_at: :desc).group_by(&:user_id)
    user_profile_hash.each_value { |profiles| Users::Profile.where(id: profiles.drop(1).map(&:id)).destroy_all }
    raise FailedDeduping unless duplicate_profile_user_ids.empty?
  end

  def duplicate_profile_user_ids
    Users::Profile.select(:user_id).group(:user_id).having("count(user_id) > 1").pluck(:user_id)
  end
end
