# 5. Use CanCanCan for authorization

Date: 2024-06-25

## Status

Accepted

## Context

We will need authorization in TACOS to support the staff user interface. Specifically, we will need to manage access
to the following features:

* The categorization interface. This is one of the core features of TACOS, in which staff will match logged search
terms to categories.
* The 'Hints' system. TACOS will provide a dashboard to manage Hints, which are currently maintained in a Google
spreadsheet.
* Reporting dashboard. Initially, TACOS will provide monthly statistics on matched algorithms. We will likely add
more reporting functionality in the future.

The authorization gem we select should also be able to support features beyond those listed above, as we are not sure
what TACOS might become in the future.

## Options considered 

For the purpose of this ADR, I considered three popular authorization gems. These are not the only available options,
but they are widely adopted and well supported.

### CanCanCan

[CanCanCan](https://github.com/CanCanCommunity/cancancan) is the gem we are familiar with, having most recently used it
in [ETD](https://github.com/MITLibraries/thing/blob/main/app/models/ability.rb). It differs from the other two gems
in its use of roles rather than policies, and a single `Ability` model to manage all roles.

This approach, while less object-oriented, makes for a simpler file structure. I also find it easier to understand
authorization when defined as roles, particularly if I can see all roles alongside each other in the same model. I have
a bias here due to my familiarity with CanCanCan, but all of us in EngX share that familiarity.

However, there is a risk of code smell in CanCanCan if we end up with complex authorization logic. The consolidation of
authorization logic can lead to an expansive `Ability` model, which can make for difficult readability and
maintainability.

### Pundit

[Pundit](https://github.com/varvet/pundit) is probably the most popular alternative to CanCanCan. In Pundit, we create
policy classes, each of which usually corresponds to a model. Within a given policy are several query methods that
correspond to different controller methods.

For example, the `HintPolicy` class might have a `update?` method, which would define the conditions under which a user
could update a hint record. We would then invoke this authorization in the Hint controller by adding `authorize @hint`
to `HintController#update`. (See the [Pundit readme](https://github.com/varvet/pundit?tab=readme-ov-file#policies)
for a more detailed example.)

Pundit also allows for more granular access control via
[scopes](https://github.com/varvet/pundit?tab=readme-ov-file#scopes). This feature is the most compelling reason to
choose Pundit over CanCanCan, but it's unclear whether we would need it in this application.

### Action Policy

[Action Policy](https://github.com/palkan/action_policy) is the newest of the gems considered here, but still
well-established (its first release was in 2018). It is based on Pundit and uses very similar conventions. The main
differences are that Action Policy offers better performance, largely via
[caching](https://actionpolicy.evilmartians.io/#/./caching).

Besides that, it seems to be a more customizable version of Pundit. That customizability is likely helpful in an
application that requires very complex authorization logic, but I don't expect TACOS to have that need.

## Ease of documentation

Because we are considering generated documentation in TACOS, an additional criterion is whether any of these gems is
better suited to this than the others. I am not familiar with RDoc or YARD, but it seems like the object-oriented nature
of Pundit and Action Policy would yield better generated docs. However, descriptive comments and role names in a
CanCanCan `Ability` model may also be adequate.

## Decision

We will use CanCanCan for authorization.

Action Policy seems to have more features than are necessary for TACOS. Unless our authorization logic becomes far more
complex than I anticipate, or we have performance issues related to authorization, it is probably not the best choice
for this application. It does seem like an intriguing option, though, and something we should consider for future use
cases.

This leaves Pundit as the alternative. The key advantages of Pundit over CanCanCan are its OO design and its use of
scopes to provide more granular control. It does seem to be more Ruby-ish, and if we were starting from zero with no
previous experience in authorization, it would probably be my choice.

In this case, though, we are already familiar with CanCanCan. This familiarity, combined with its relative simplicity,
gives it the edge in an application that should have fairly straightforward authorization.

## Consequences

If our authorization logic becomes more complex than expected, then we risk a bloated `Ability` model. This could cause
readability and maintenance challenges.

We may also find, after developing TACOS further, that scoped authorization would be useful,
or even necessary. In that case, we might consider migrating our authorization logic to either Pundit or Action Policy.
While CanCanCan does offer a
[similar feature](https://github.com/CanCanCommunity/cancancan/blob/develop/docs/define_abilities_with_blocks.md#block-conditions-with-activerecord-scopes), it's a bit clunky and not as intuitive (to my eyes) as Pundit's convention.

By not selecting Action Policy, we are forgoing its performance gains. This feels like an acceptable risk, as I am
unaware of any performance issues we've encountered with CanCanCan.
