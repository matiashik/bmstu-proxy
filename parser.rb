module Parser
  class << self
    def public(raw)
      schedule = raw.dig("data", "schedule")

      schedule.map do |unit|
        {
          day: unit["day"],
          order: unit["time"],
          time: "#{unit["startTime"]} - #{unit["endTime"]}",
          teachers: unit["teachers"].map { it.slice("lastName", "firstName", "middleName").values.join(" ") }.join(", "),
          place: unit["audiences"].map { it.slice("name", "building").values.join(" ") }.join(", "),
          discipline: unit.dig("discipline", "fullName"),
          type: act_type(unit.dig("discipline", "actType")),
          week: unit["week"].to_sym # all ch zn
        }
      end
    end

    def current(raw)
      data = raw["data"]

      {
        name: data["weekName"].capitalize,
        week: week_short_name(data["weekShortName"]),
        number: data["weekNumber"],
        day: day(raw["date"])
      }
    end

    private

    def act_type(type)
      case type
      when "lecture"
        "Лекция"
      when "seminar"
        "Семинар"
      when "generated", nil
        ""
      else
        type
      end
    end

    def week_short_name(name)
      case name
      when "чс"
        :ch
      when "зн"
        :zn
      end
    end

    def day(datetime)
      Time.new(datetime).wday
    end
  end
end
