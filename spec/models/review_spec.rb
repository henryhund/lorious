require 'spec_helper'

describe Review do
  context "creating a review" do
    let(:user) { FactoryGirl.create :user }
    let(:expert) { FactoryGirl.create :expert }
    let(:review) { FactoryGirl.create :review, reviewed_id: expert.id, reviewer_id: user.id, rating: 3 }
    it "should link reviewed for review" do
      review.reviewed.should == expert
      expert.reviews_received.should == [review]
    end
    it "should link reviewer for review" do
      review.reviewer.should == user
      user.reviews_made.should == [review]
    end
  end
end
