require "spec_helper"

describe User do
  context "associations" do
    it { should have_many :reviews_made }
    it { should have_many :reviews_received }
    it { should have_many :appointments }
    it { should have_many :social_media }
  end

  context "mailboxer" do
    let(:user1) { FactoryGirl.create :user }
    let(:user2) { FactoryGirl.create :user }
    it "user2 inbox should have the message" do
      user1.send_message(user2, "Body", "subject")
      user2.mailbox.inbox.count.should be(1)
      user2.mailbox.inbox.first.subject.should == "subject"
      user2.mailbox.inbox.first.messages.first.body.should == "Body"
    end
  end

  context "geocoder" do
    let(:user) { FactoryGirl.create :user, location: "bangalore" }
    it "should fetch latitude and longitude for the user" do
      user.latitude.should_not be_nil
      user.longitude.should_not be_nil
    end
  end
end
