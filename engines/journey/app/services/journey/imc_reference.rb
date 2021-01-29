module Journey
  class ImcReference
    attr_reader :date

    def initialize(date:)
      @date = date
    end

    def reference
      [day_and_hour, minutes_and_seconds].join
    end

    def day_and_hour
      day_of_the_year = date.strftime("%d%m")
      hour_as_letter = ("A".."Z").to_a[date.hour - 1]
      year = date.year.to_s[-2..-1]
      day_of_the_year + hour_as_letter + year
    end

    def minutes_and_seconds
      "#{date.strftime("%M")}#{date.strftime("%S")}#{date.strftime("%L")[0..1]}"
    end
  end
end
