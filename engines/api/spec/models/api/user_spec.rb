# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::User, type: :model do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.build(:api_user) }
  let!(:asc_user) do
    FactoryBot.create(:api_user,
      email: "aaa@itsmycargo.test",
      last_activity_at: 2.weeks.ago.to_s,
      profile: FactoryBot.build(:users_profile, first_name: "adam", last_name: "art", phone: "9111222333"))
  end
  let!(:desc_user) do
    FactoryBot.create(:api_user,
      email: "bbb@itsmycargo.test",
      last_activity_at: 1.day.ago.to_s,
      profile: FactoryBot.build(:users_profile, first_name: "zulu", last_name: "xi", phone: "9222333444"))
  end

  before do
    ::Organizations.current_id = organization.id
  end

  it "builds a valid user" do
    expect(user).to be_valid
  end

  describe "#sorted_by" do
    let(:sorted_users) { described_class.sorted_by(sort_by) }

    context "when sorted by email asc" do
      let(:sort_by) { "email_asc" }

      it "returns clients based on email in ascending order" do
        expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
      end
    end

    context "when sorted by email desc" do
      let(:sort_by) { "email_desc" }

      it "returns clients based on email in descending order" do
        expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
      end
    end

    context "when sorted by `last_activity_at` asc" do
      let(:sort_by) { "activity_asc" }

      it "returns clients based on email in ascending order" do
        expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
      end
    end

    context "when sorted by `last_activity_at` desc" do
      let(:sort_by) { "activity_desc" }

      it "returns clients based on email in descending order" do
        expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
      end
    end

    context "when sorting based on profile attributes" do
      context "when sorted by first_name asc" do
        let(:sort_by) { "first_name_asc" }

        it "returns clients based on first_name in ascending order" do
          expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
        end
      end

      context "when sorted by first_name desc" do
        let(:sort_by) { "first_name_desc" }

        it "returns clients based on first_name in descending order" do
          expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
        end
      end

      context "when sorted by last_name asc" do
        let(:sort_by) { "last_name_asc" }

        it "returns clients based on last_name in ascending order" do
          expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
        end
      end

      context "when sorted by last_name desc" do
        let(:sort_by) { "last_name_desc" }

        it "returns clients based on last_name in descending order" do
          expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
        end
      end

      context "when sorted by phone asc" do
        let(:sort_by) { "phone_asc" }

        it "returns clients based on phone in ascending order" do
          expect(sorted_users.map(&:id)).to eq([asc_user.id, desc_user.id])
        end
      end

      context "when sorted by phone desc" do
        let(:sort_by) { "phone_desc" }

        it "returns clients based on phone in descending order" do
          expect(sorted_users.map(&:id)).to eq([desc_user.id, asc_user.id])
        end
      end

      context "without matching sort_by scope" do
        let(:sort_by) { "nonsense_desc" }

        it "returns default direction" do
          expect { sorted_users }.to raise_error(ArgumentError)
        end
      end
    end
  end

  context "when filtering users by email" do
    it "returns client with email `bbb@itsmycargo.test`" do
      expect(described_class.email_search("bbb").pluck(:email)).to eq(["bbb@itsmycargo.test"])
    end
  end

  context "when filtering users by last_name" do
    it "returns client with last name `xi`" do
      expect(described_class.last_name_search("xi").pluck(:last_name)).to eq(["xi"])
    end
  end

  context "when filtering users by phone" do
    it "returns client with phone number `9111222333`" do
      expect(described_class.phone_search("9111222333").pluck(:phone)).to eq(["9111222333"])
    end
  end

  context "when filtering users by last activity" do
    it "returns client with activity older 3 days" do
      expect(described_class.activity_search(4.weeks.ago..3.days.ago)).to eq([asc_user])
    end

    it "returns client with activity in this week" do
      expect(described_class.activity_search(1.week.ago..Time.zone.today.to_s)).to eq([desc_user])
    end
  end
end
