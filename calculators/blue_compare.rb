class BlueCompare < AwardCalculator
  def update
    if @award.quality < max_quality
      increase_quality_by 1

      if @award.expires_in < 11
        increase_quality_by 1
      end

      if @award.expires_in < 6
        increase_quality_by 1
      end
    end

    @award.expires_in -= 1

    @award.quality = 0 if expired?
  end
end

AwardQualityCalculators.provide('Blue Compare', BlueCompare)
