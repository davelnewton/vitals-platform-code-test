require 'award'

class AwardQualityCalculator
  def initialize
    @calculators = {
      "Blue Distinction Plus" => BlueDistinctionPlus.new,
      "Blue First" => BlueFirst.new,
      "Blue Compare" => BlueCompare.new
    }
  end

  def update(award)
    calculator = @calculators.fetch(award.name) { Other.new }
    calculator.update(award)
  end
end

# Unknown/other names.
class Other
  def update(award)
    if award.quality > 0
      award.quality -= 1
    end

    award.expires_in -= 1

    if award.expires_in < 0
      if award.quality > 0
        award.quality -= 1
      end
    end
  end
end

# Blue Distinction Plus: never
# expire and never change quality.
class BlueDistinctionPlus
  def update(award)
    # Does nothing.
  end
end

class BlueFirst
  def expired?(award)
    award.expires_in < 0
  end

  def increase_and_adjust_quality(award, n)
    award.quality += 1
    award.quality = 50 if award.quality > 50
  end

  def update(award)
    increase_and_adjust_quality award, 1

    award.expires_in -= 1

    if expired?(award)
      increase_and_adjust_quality award, 1
    end
  end
end

class BlueCompare
  def update(award)
    if award.quality < 50
      award.quality += 1
      if award.name == 'Blue Compare'
        if award.expires_in < 11
          if award.quality < 50
            award.quality += 1
          end
        end

        if award.expires_in < 6
          if award.quality < 50
            award.quality += 1
          end
        end
      end
    end

    award.expires_in -= 1

    if award.expires_in < 0
      award.quality = 0
    end
  end
end

def update_quality(awards)
  awards.each do |award|
    AwardQualityCalculator.new.update(award)
  end
end
