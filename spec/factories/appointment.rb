FactoryGirl.define do
  factory :appointment do
    time Time.now - 9.days
    duration 30
    place "Place"
    expert_confirmed false
    subject "Subject"
    description "Description"
  end
end
