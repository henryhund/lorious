require 'spec_helper'

describe Availability do
  context "associations" do
    it { should belong_to :expert }
  end

  context "get time zone difference in minutes from gmt when location provided" do
    let(:availability) { FactoryGirl.create :availability, time_zone: "Hawaii" }
    it "should return -600" do
      availability.get_time_zone_difference_in_minutes_from_gmt.should eq(-600)
    end
  end
end
