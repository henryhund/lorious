class Availability < ActiveRecord::Base
  belongs_to :expert

  TOTAL_MINUTES_IN_WEEK = 24 * 7 * 60

  def set_availability_in_gmt(availability, timezone_in_minutes, availability_unit_in_minutes)
    self.timezone_in_minutes = timezone_in_minutes
    availability = availability.map do |each|
      each["start_time"] = convert_time_to_gmt(each["start_time"], timezone_in_minutes)
      each["end_time"] = convert_time_to_gmt(each["end_time"], timezone_in_minutes)
      each
    end
    self.timespans = availability.to_json
  end

  def is_free? availability, timezone_in_minutes
    timespans_hash = JSON.parse timespans
    matched_timespan = timespans_hash.select do |t|
      availability["start_time"] >= t["start_time"] && availability["end_time"] <= t["end_time"]
    end
    matched_timespan.any?
  end

  private

  def convert_time_to_gmt time, timezone
    time = time - timezone
    if time < 0
      time = TOTAL_MINUTES_IN_WEEK + time
    end
    time
  end
end
