require 'spec_helper'

describe Appointment do
  context "associations" do
    it { should belong_to :expert }
    it { should belong_to :user }
  end

  context "total credit cost" do
    let(:expert) { FactoryGirl.create(:expert) }
    let!(:availability) { FactoryGirl.create :availability, expert_id: expert.id, hourly_cost: 100 }
    let(:user) { FactoryGirl.create(:user) }
    let(:appointment) { FactoryGirl.create :appointment, user_id: user.id, expert_id: expert.id, duration: 90  }
    it "should return 150" do
      appointment.total_credit_cost.should == 150
    end
  end

  context "appointment with for specified user" do
    let(:expert) { FactoryGirl.create(:expert) }
    let!(:availability) { FactoryGirl.create :availability, expert_id: expert.id, hourly_cost: 100 }
    let(:user) { FactoryGirl.create(:user) }
    let(:appointment) { FactoryGirl.create :appointment, user_id: user.id, expert_id: expert.id, duration: 90  }
    it "should return opposite user for the passed user" do
      appointment.appointment_with_for_user(expert).should == user &&
        appointment.appointment_with_for_user(user).should == expert
    end
  end
end
