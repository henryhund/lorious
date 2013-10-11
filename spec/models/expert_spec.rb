describe Expert do
  context "associations" do
    it { should have_one :availability }
    it { should have_many :appointments }
    it { should have_many :expertise }
  end

  context "expert" do
    let(:expert) { Expert.create email: "sample@sample.com", password: "password123" }
    it "should be of type Expert" do
      expert.type.should == "Expert"
    end
  end

  context "expert skills" do
    let(:expert) { FactoryGirl.create :expert }
    context "no skills assigned" do
      it "should have empty skills" do
        expert.skills.should == []
      end      
    end
    context "assigned skills should be shown" do
      it "should return assigned skills" do
        expert.skill_list.add "Web"
        expert.save
        expert.skill_list.should == ["Web"]
        Expert.tagged_with(["Web"], :match_all => true).should == [expert]
      end
    end
  end

  context "set availability" do
    let(:expert) { FactoryGirl.create :expert }
    let(:set_availability) { expert.set_availability([{"start_time" => 30, "end_time" => 60}, {"start_time" => 180, "end_time" => 210}], 120) }
    it "should return availability object" do
      set_availability.class.should == Availability
    end
    it "should save availability in gmt" do
      JSON.parse(set_availability.timespans).should == [{"start_time" => 9990, "end_time" => 10020}, {"start_time" => 60, "end_time" => 90}]
    end
  end

  context "get availability" do
    let(:expert) { FactoryGirl.create :expert }
    let!(:set_availability) { expert.set_availability([{"start_time" => 30, "end_time" => 60}, {"start_time" => 180, "end_time" => 210}], 120) }
    context "if expert is available" do
      let(:get_availability) { expert.get_availability({"start_time" => 60, "end_time" => 90}, -30) }
      it "should return true" do
        get_availability.should be_true
      end
    end
    context "if expert is not available" do
      let(:get_availability) { expert.get_availability({"start_time" => 360, "end_time" => 420}, -30) }
      it "should return false" do
        get_availability.should be_false
      end
    end
  end
end
