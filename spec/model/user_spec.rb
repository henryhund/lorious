require "spec_helper"

describe User do
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

  context "expert" do
    let(:expert) { Expert.create email: "sample@sample.com", password: "password123" }
    it "should be of type Expert" do
      expert.type.should == "Expert"
    end
  end
end
