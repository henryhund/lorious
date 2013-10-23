class Availability < ActiveRecord::Base
  belongs_to :expert

  TOTAL_MINUTES_IN_WEEK = 24 * 7 * 60

  def set_availability_in_gmt(timespans_hash, timezone_in_minutes, availability_unit_in_minutes)
    self.timezone_in_minutes = timezone_in_minutes
    timespans_hash = timespans_hash.map do |each|
      each["start_time"] = convert_time_to_gmt(each["start_time"], timezone_in_minutes)
      each["end_time"] = convert_time_to_gmt(each["end_time"], timezone_in_minutes)
      each
    end
    self.timespans = timespans_hash.to_json
    self.save!
    self.timespans
  end

  def timespan_in_timezone timezone
    JSON.parse(timespans).map do |each|
      each["start_time"] = convert_time_to_given_timezone(each["start_time"], timezone)
      each["end_time"] = convert_time_to_given_timezone(each["end_time"], timezone)
      each
    end
  end

  def is_free? availability, timezone_in_minutes
    timespans_hash = JSON.parse timespans
    matched_timespan = timespans_hash.select do |t|
      availability["start_time"] >= t["start_time"] && availability["end_time"] <= t["end_time"]
    end
    matched_timespan.any?
  end

  def get_time_zone_difference_in_minutes_from_gmt
    ActiveSupport::TimeZone.new(time_zone).utc_offset / 60
  end

  private

  def convert_time_to_gmt time, timezone
    time = time - timezone
    if time < 0
      time = TOTAL_MINUTES_IN_WEEK + time
    elsif time >= TOTAL_MINUTES_IN_WEEK
      time = time - TOTAL_MINUTES_IN_WEEK
    end
    time
  end

  def convert_time_to_given_timezone time, timezone
    time = time + timezone
    if time < 0
      time = TOTAL_MINUTES_IN_WEEK + time
    end
    time
  end
end
