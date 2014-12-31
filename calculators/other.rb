class Other < AwardCalculator
  def update
    lower_quality_by 1
    @award.expires_in -= 1
    lower_quality_by 1 if expired?
  end
end

AwardQualityCalculators.provide('Other', Other)
