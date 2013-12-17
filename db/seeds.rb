# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ first_name: 'Chicago' }, { first_name: 'Copenhagen' }])
#   Mayor.create(first_name: 'Emanuel', city: cities.first)

Setting.destroy_all
Setting.create(name: "hours_cancellation_allowed", value: "8")
Setting.create(name: "hours_edit_allowed", value: "8")
Setting.create(name: "minimum_transaction_amount", value: "20")

Setting.create(name: "google_hangout_show_hours_before", value: "1")
Setting.create(name: "support_email_id", value: "support@lorious.com")

Setting.create(name: "slot_1_limit", value: "30")
Setting.create(name: "slot_2_limit", value: "40")
Setting.create(name: "slot_3_limit", value: "50")

Setting.create(name: "slot_1_percent", value: "30")
Setting.create(name: "slot_2_percent", value: "20")
Setting.create(name: "slot_3_percent", value: "10")

Expert.order("RANDOM()").all(:limit => 4).each do |expert| 
  expert.is_featured = true
  expert.save
end