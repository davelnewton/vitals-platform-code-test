# Blue Distinction Plus: never
# expire and never change quality.
class BlueDistinctionPlus < AwardCalculator
  def max_quality; 80; end

  def update
    if @award.quality != 80
      raise 'Improper update of Blue Distinction Plus quality; must remain 80'
    end
  end
end

AwardQualityCalculators.provide('Blue Distinction Plus', BlueDistinctionPlus)
