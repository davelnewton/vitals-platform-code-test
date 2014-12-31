class BlueStar < AwardCalculator
  def update
    lower_quality_by 2
    @award.expires_in -= 1
    lower_quality_by 2 if expired?
  end
end

AwardQualityCalculators.provide('Blue Star', BlueStar)
