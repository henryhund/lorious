class AddTimeZoneToAvailability < ActiveRecord::Migration
  def change
    add_column :availabilities, :time_zone, :string
  end
end
