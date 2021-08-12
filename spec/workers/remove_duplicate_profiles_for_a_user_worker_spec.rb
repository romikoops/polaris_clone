# frozen_string_literal: true

require "rails_helper"
RSpec.describe RemoveDuplicateProfilesForAUserWorker, type: :worker do
  describe "#perform" do
    let!(:users_user_id) { FactoryBot.create(:users_user).id }
    let!(:user_pro1) do
      FactoryBot.build(:users_profile, user_id: users_user_id,
                                       updated_at: Time.zone.yesterday).tap { |profile| profile.save(validate: false) }
    end
    let!(:user_pro2) do
      FactoryBot.build(:users_profile, user_id: users_user_id,
                                       company_name: "New Company",
                                       updated_at: Time.zone.tomorrow).tap { |profile| profile.save(validate: false) }
    end

    it "deletes the profile which was updated least recent" do
      expect { described_class.new.perform }.to change { Users::Profile.with_deleted.find(user_pro1.id).deleted? }.from(false).to(true)
    end

    it "does not delete the recently updated profile" do
      expect { described_class.new.perform }.not_to(change { Users::Profile.with_deleted.find(user_pro2.id).deleted? })
    end

    it "raises an exception if duplicate profiles still exist" do
      described_class_instance = described_class.new
      allow(described_class_instance).to receive(:duplicate_profile_user_ids).and_return([users_user_id])
      expect { described_class_instance.perform }.to raise_error(StandardError)
    end
  end
end
