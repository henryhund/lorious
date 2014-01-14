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

  context "timespans in specified timezone" do
    let(:timespans) { [{"start_time" => 30, "end_time" => 60}, {"start_time" => 180, "end_time" => 210}] }
    let(:availability) { FactoryGirl.create :availability, timespans: timespans.to_json, time_zone: "EST", timezone_in_minutes: -300 }
    it "should change start_time and end_time for availability" do
      availability.timespan_in_timezone(availability.timezone_in_minutes).should eq([{"start_time" => 9810, "end_time" => 9840}, {"start_time" => 9960, "end_time" => 9990}])
    end
  end
end
