require 'award'

class AwardQualityCalculator
  def initialize
    @calculators = {
      "Blue Distinction Plus" => BlueDistinctionPlus,
      "Blue First" => BlueFirst,
      "Blue Compare" => BlueCompare,
      "Blue Star" => BlueStar
    }
  end

  def update(award)
    calculator = @calculators.fetch(award.name, Other)
    calculator.new(award).update
  end
end

class AwardCalculator
  def initialize(award)
    @award = award
  end

  def expired?
    @award.expires_in < 0
  end

  def increase_quality_by(n=1)
    @award.quality += n
    @award.quality = max_quality if @award.quality > max_quality
  end

  def max_quality
    50
  end

  def lower_quality_by(n=1)
    return if @award.quality == 0
    @award.quality -= n
  end

  # Default award blows up: enforce subclass impl.
  def update
    raise 'Unimplemented award type update!'
  end
end

# Unknown/other names.
class Other < AwardCalculator
  def update
    lower_quality_by 1
    @award.expires_in -= 1
    lower_quality_by 1 if expired?
  end
end

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

class BlueFirst < AwardCalculator
  def update
    increase_quality_by 1
    @award.expires_in -= 1
    increase_quality_by 1 if expired?
  end
end

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

class BlueStar < AwardCalculator
  def update
    lower_quality_by 2
    @award.expires_in -= 1
    lower_quality_by 2 if expired?
  end
end

def update_quality(awards)
  calculator = AwardQualityCalculator.new

  awards.each do |award|
    calculator.update(award)
  end
end
