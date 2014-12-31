class BlueFirst < AwardCalculator
  def update
    increase_quality_by 1
    @award.expires_in -= 1
    increase_quality_by 1 if expired?
  end
end

AwardQualityCalculators.provide('Blue First', BlueFirst)
