# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ first_name: 'Chicago' }, { first_name: 'Copenhagen' }])
#   Mayor.create(first_name: 'Emanuel', city: cities.first)

Setting.destroy_all
Setting.create(name: "hours_cancellation_allowed", value: "8")
Setting.create(name: "minimum_transaction_amount", value: "20")
Setting.create(name: "lorious_service_charge_percent", value: "25")
