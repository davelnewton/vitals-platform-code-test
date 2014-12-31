require 'award'
require 'award_calculators'

def update_quality(awards)
  awards.each do |award|
    AwardQualityCalculators.update(award)
  end
end
