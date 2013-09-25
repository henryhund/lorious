describe Expert do
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
end
