require 'award'

class AwardQualityCalculator
  def initialize
    @calculators = {
      "Blue Distinction Plus" => BlueDistinctionPlus,
      "Blue First" => BlueFirst,
      "Blue Compare" => BlueCompare
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

  # Default award blows up: enforce subclass impl.
  def update
    raise 'Unimplemented award type update!'
  end
end

# Unknown/other names.
class Other < AwardCalculator
  def update
    if @award.quality > 0
      @award.quality -= 1
    end

    @award.expires_in -= 1

    if @award.expires_in < 0
      if @award.quality > 0
        @award.quality -= 1
      end
    end
  end
end

# Blue Distinction Plus: never
# expire and never change quality.
class BlueDistinctionPlus < AwardCalculator
  def update
    # Does nothing.
  end
end

class BlueFirst < AwardCalculator
  def initialize(award)
    @award = award
  end

  def expired?
    @award.expires_in < 0
  end

  def increase_and_adjust_quality(n)
    @award.quality += 1
    @award.quality = 50 if @award.quality > 50
  end

  def update
    increase_and_adjust_quality 1

    @award.expires_in -= 1

    if expired?
      increase_and_adjust_quality 1
    end
  end
end

class BlueCompare < AwardCalculator
  def update
    if @award.quality < 50
      @award.quality += 1
      if @award.name == 'Blue Compare'
        if @award.expires_in < 11
          if @award.quality < 50
            @award.quality += 1
          end
        end

        if @award.expires_in < 6
          if @award.quality < 50
            @award.quality += 1
          end
        end
      end
    end

    @award.expires_in -= 1

    if @award.expires_in < 0
      @award.quality = 0
    end
  end
end

def update_quality(awards)
  calculator = AwardQualityCalculator.new

  awards.each do |award|
    calculator.update(award)
  end
end
