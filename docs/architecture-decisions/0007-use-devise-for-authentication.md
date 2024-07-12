# 7. Use Devise for authentication

Date: 2024-07-11

## Status

Accepted

## Context

We will need to authenticate users in TACOS to help manage access to the staff interface. The ideal authentication
approach would involve Omniauth integration, as IS&T recently implemented Okta, and
[a strategy exists](https://github.com/omniauth/omniauth_openid_connect) to authenticate with OIDC using Omniauth.

## Options considered

### [Devise](https://github.com/heartcombo/devise)

Devise is the far and away the most popular authentication gem, and the one with which we have the greatest familiarity.
It is well-documented and feature-rich, and it integrates seamlessly with Omniauth, which we will likely use to work
with Okta.

Devise is also something of a black box, and its extensibility causes a steep learning curve. All of us in EngX have
worked with Devise, but not all of us have configured it from scratch in a new application. As a result, our collective
understanding of how the gem works is fairly limited.

We also anticipate fairly straightforward authentication needs for this application, so its extensibility may just add
complexity and not value.

### [Sorcery](https://github.com/Sorcery/sorcery)

Sorcery positions itself as a simpler alternative to Devise. It uses only 20 public methods, which follow familiar
conventions (e.g., `current_user` and `logged_in?`). Though other gems also strive for simplicity (see Clearance,
below), Sorcery seems to be most successful in this.
[Some have switched to it from Clearance](https://github.com/Sorcery/sorcery/issues/248#issuecomment-1306195246) for
this reason.

The downside of simplicity is it does not include features we'd need, such as
[integration with Omniauth](https://github.com/omniauth/omniauth/issues/1042). Some customization would be required.
I've not yet found a sample implementation with Omniauth, so we might need to figure it out on our own. It's also
notable that Sorcery is not yet in v1, and he have struggled at times to keep up with changes in pre-major-release
gems (Administrate is the first example that comes to mind).

### [Clearance](https://github.com/thoughtbot/clearance)

Clearance is another popular option. Like Sorcery, it offers a simpler approach than Devise. It's opinionated, which
makes for quicker setup, but it also claims to make it easy to override defaults. Anecdotally, this claim
[appears to be true](https://everydayrails.com/2016/01/23/clearance-rails-authentication#sensible-defaults), but the
defaults would likely be sufficient for us.

Also like Sorcery, Clearance has no Omniauth integration. [This gist](https://gist.github.com/stevebourne/2394427) gives
a sense of what might be required to build out that feature.

Clearance seems to be less ubiquitous than Sorcery, but more regularly maintained. Despite the lower adoption rate,
Clearance appears to have a very helpful user community, as demonstrated by the gist shared above.

### [Authlogic](https://github.com/binarylogic/authlogic)

Authlogic is a highly customizable authentication solution, and with more than 10 million downloads on RubyGems, it
appears to be the second most popular option after Devise. However, because it is so customizable, it has a steeper
learning curve than some of the alternatives. It is also less actively maintained, with no releases so far this year
and only 3 since 2021.

### Custom solution

We could build out our own authentication code. [Here is an example](https://stevepolito.design/blog/rails-authentication-from-scratch)
of this approach, and another [Omniauth-specific example](https://github.com/omniauth/omniauth?tab=readme-ov-file#rails-without-devise).

This approach would reduce our reliance on dependencies, and it may help us understand our application better. Many
authentication gems use a fair amount of magic to make them easier to implement, but this can also make it difficult
to understand how they work.

However, this approach would also introduce the signfiicant risk of writing and maintaining our own authentication code.
We might consider the [Authentication Zero](https://github.com/lazaronixon/authentication-zero) to generate the initial
code, which would significantly speed up implementation, but maintenance would still become our responsibility. If we
use a preexisting gem, we are effectively delegating that responsibility to others that presumably have more expertise
in this space.

## Decision

We will use Devise for authentication. Despite its complexity and opacity, Devise is the most popular authentication gem
by a wide margin. We already have some familiarity with it, and we use it in our other applications. While we will not
need the vast majority of its features, we likely will use the Omniauth integration, which will save us from writing
some additional code.

Sorcery and Clearance are compelling due to their ease of use. However, they may end up being _more_ complex to
implement due to their lack of Omniauth integration.

Authlogic feels equally complex as Devise, albeit more transparent. It also seems not to be especially well maintained.

A custom solution would be an interesting way leverage built-in Rails functionality while reducing our reliance on
third-party libraries. However, it is difficult to justify considering the additional risk and development time.

Ultimately, while all of these alternatives are appealing, there is a distinct advantage to choosing a gem that "just
works" and is widely adopted. Much like our
[decision to use CanCanCan for authorization](https://github.com/MITLibraries/tacos/blob/main/docs/architecture-decisions/0006-use-cancancan-for-authorization.md), I might not feel like Devise is the best authentication gem, but I have
a difficult time convincing myself not to use it for this project.

## Consequences

To choose Devise is to double-down on a gem that is a black box. Whether we build our own solution or adopt a more
streamlined gem, there is an opportunity to gain a greater understanding of this critical feature, and possibly
even build expertise in Rails security. This decision effectively sacrifices that opportunity for the sake of
convenience.
