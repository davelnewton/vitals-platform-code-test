class AwardQualityCalculators
  @calculators = {}

  def self.provide(name, clazz)
    @calculators[name] = clazz
  end

  def self.update(award)
    calculator = @calculators.fetch(award.name, @calculators.fetch('Other'))
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

Dir.glob('calculators/**/*.rb').each { |f| require f }
