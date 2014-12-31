Table of Contents
=================

* [Implementation Notes](#implementation-notes)
    * [`AwardQualityCalculators`](#awardqualitycalculators)
        * [Usage](#usage)
    * [`AwardCalculator`](#awardcalculator)
        * [Usage](#usage-1)
    * [Loading Calculators](#loading-calculators)
    * [Assumptions](#assumptions)
* [Caveats, Notes, Questions I'd Discuss With Team IRL](#caveats-notes-questions-id-discuss-with-team-irl)
    * [Award Calculator Self-Registration](#award-calculator-self-registration)
    * [`AwardCalculator` Hierarchy and Implementation](#awardcalculator-hierarchy-and-implementation)
    * [String Identifiers](#string-identifiers)
    * [RSpec and Contexts](#rspec-and-contexts)
    * ["Thread" Safety](#thread-safety)

# Implementation Notes

## `AwardQualityCalculators`

* Trivial, dirty "plugin" mechanism
* Static class allows registration of award type calculators by name
* All quality score updates should go through this class

### Usage

**Registration**

    AwardQualityCalculators.provide(an_award_name, an_award_calculator_class)

**Quality Calculation**

    AwardQualityCalculators.update(an_award)

## `AwardCalculator`

Base class that has a couple of utility methods that most (all?) quality calculators might use. Composites the `Award` that's being updated (this is shady).

### Usage

* The base class defines a `max_quality` function. Subclasses may update this.
* Each `AwardCalculator` must define its own `update` method. Not defining this method is an error.

## Loading Calculators

* Requiring `award_calculators` loads each of the classes in the `calculators` directory.
* Each of those classes registers itself after its declaration.

## Assumptions

* The directory holds only award quality calculators.
* Each calculator registers itself with `AwardQualityCalculators`.

# Caveats, Notes, Questions I'd Discuss With Team IRL

## Award Calculator Self-Registration

Overkill, and I know it.

Originally I created the map manually, but IRL I would rarely do that, especially if it's a mechanism that's likely to change or need extension.

Having each calculator register itself during class loading is fluff, but I preferred it there as it kept things a bit more isolated. It's bad, because to *not* register something means you have to visit the calculator's file instead of having it all in one place.

Normally I wouldn't have the `AwardCalculator` in the same file as the plugin registry; that's an artifact of not wanting to play games with load paths and keeping things simple-ish.

## `AwardCalculator` Hierarchy and Implementation

In general I'm not a huge fan of inheritance, but as the code currently stands, it seemed reasonable.

I pass the award in to the base class ctor so the hierarchies' implementations have easy access to award properties. It's basically composition (a good thing) but as it stands, it seems like `update` is working at multiple levels of abstraction, e.g., hitting `@award` properties directly. I'm iffy on this.

I don't like modifying the composited class in what is essentially a decorator. The reason I do is (a) `Award`, being a struct, has no easy mechanism to hang functionality on, and (b) once I'm in the calculator, I don't want to pass around an `Award` everywhere.

The calculators are a cross between a decorator and a service, sort of. Service in the sense that it's operating on a single award, decorator in the sense that I really didn't want to pass awards between every single method. Also decorator in the sense that there's one per award, solving one class of concurrency issues, but not the underlying issue of mutable awards.

## String Identifiers

The awards are just structs. IRL I'd probably have a more official way of identifying award types (e.g., enum, symbol, class) and associating quality calculators besides string => impl.

## RSpec and Contexts

* I didn't alter the spec to use RSpec 3; IRL I probably would.
* I would create each `Award` "locally", e.g., right before the test.

I find the reliance of `let` ordering in specs to be foofy. I'd create each `Award` at the point of the spec instead of using the defaults in the top context and the overrides at the spec. It's short enough that there's no reason to make people have to think about what all the values will be by the time it's created.

## "Thread" Safety

IRL an `Award` would probably need to be treated with a bit more respect with regards to concurrent modifications etc. Right now the calculators are working on whatever award is given to it, which is almost always bad.

----

# Vitals Code Test

# Description
Hi, and welcome to the team! As you know, we provide tools for searching for doctors and hospitals (i.e. "providers") based on various criteria. One type of search that we provide is to find providers that are highly rated by quality.

To calculate quality, one measure we use is a score based on professional award recognitions. Each award is factored in slightly differently.

- All awards have an expires_in value which denotes the number of days until the award expires.

- All awards have a quality value which denotes how valuable the award is in our overall calculation.

- At the end of each day our system recalculates both values for every award based on business rules.

Pretty basic. But here is where it gets interesting...

  - Once the expiration date has passed, quality score degrades twice as fast

  - The quality of an award is never negative.

  - "Blue First" awards actually increase in quality the older they get

  - The quality of an award is never more than 50

  - "Blue Distinction Plus", being a highly sought distinction, never decreases in quality

  - "Blue Compare", similar to "Blue First", increases in quality as the expiration date approaches; Quality increases by 2 when there are 10 days or less left, and by 3 where there are 5 days or less left, but quality value drops to 0 after the expiration date.

  - Just for clarification, an award can never have its quality increase above 50, however "Blue Distinction Plus", being highly sought, its quality is 80 and it never alters.

We have recently gotten a request from our clients to include an additional award in our quality calculations. This requires an update to our system.

# Your Assignment

Here is the business story:

- In order to distinguish between providers of high quality, as a consumer, I want to see "Blue Star" awarded providers near the top of the results when the award is initially granted, but it's impact should be smaller the longer it has been from the grant date.

- Acceptance Criteria
  - "Blue Star" awards should lose quality value twice as fast as normal awards.

During Sprint Planning, you estimated the story to be between 1 and 3 story points (in general, this corresponds to a few hours to a couple of days). We have committed to complete this by the end of our Sprint which ends soon. Please fork the code and submit a link to your fork with your changes when you have completed the assignment.

The existing code is "legacy", and, ugh, it's ugly. Feel free to make any changes to the code as long as everything still works correctly and all specs pass. (Although, note that Awards are used elsewhere in the system, so their public interface must remain backward compatible).

## Installation Hints

The easiest way is to use bundler to install the dependencies. To do so, you need to install the bundler gem if you havent already done so

    gem install bundler

run bundler

    bundle

and should be ready to go. Alternatively, you can install the dependencies one by one using gem install, e.g.

    gem install rspec

Have a look at the Gemfile for all dependencies.

## Testing

To test your work, run the default rake task:

    rake


