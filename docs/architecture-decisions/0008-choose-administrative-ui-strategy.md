# 8. Choose administrative UI strategy

Date: 2024-07-11

## Status

Accepted

## Context

Part of the TACOS application involves the maintenance of records: specific
phrases that should trigger bespoke responses, notes received from staff who
participate in the categorization process, etc. Other records, like the set of
search terms, any derived metadata from those terms, and imported records like
journal titles, might be viewable at least (if not editable).

Because of these needs, the application has a need for an administrative
interface to view - and potentially edit - those records. The Rails community
has produced a variety of gems for this type need, which provide ready-made
administrative interfaces for content management.

We need to decide whether to use one of these gems, or whether it would be
better to build a bespoke interface for exploring and managing these records.

## Options considered

While there are a large number of [gems which attempt to provide an
administrative interface](https://ruby.libhunt.com/gems/admin-interface), we only focused on a handful for this decision. Many
of those options were included in a helpful [Admin Panel Comparison application](https://github.com/lorint/admin_panel_comparison).

### Administrate gem

https://rubygems.org/gems/administrate

Administrate is the option we've used for our ETD application, which has been a
mixed experience. While it has been nice to get content administration easily,
the process of customizing these interfaces to implement business logic has
meant customizing built-in templates, which then need to be maintained as the
underlying gem continues to develop. That maintenance can be unpredictable, and
managing the changes can be tricky for large refactors.

### Avo gem

https://rubygems.org/gems/avo

Avo has been mentioned favorably in some recent community discussions among
Rails developers, and it is included as one of the options in a demonstration
app that compares several commonly-used gems.

Unfortunately, Avo wants to push users to subscribe to its hosted service, and
the data flowing through TACOS is sensitive enough that it should not be sent
to these types of platforms without significant vetting.

### No gem - bespoke administration

Given that some records within TACOS should probably be read-only (we probably
don't want to allow editing of search terms, for example), while other records
may have editable fields alongside read-only fields, there is a chance that we
would need to heavily customize _any_ stock administrative gem. By contrast, it
is not hard to build an admin interface using built-in Rails tooling.

While the complexity of our own business logic is unavoidable, we might simplify
the process of satisfying that business logic by working purely in our own code,
avoiding the need to mediate between the opinionated implementation of an admin
gem and our own idiosyncratic opinions.

## Decision

We will use Administrate for now, but keep a very close eye on how much we are
customizing its UI. Our first instinct, rather than customize the Administrate
gem, should be to build out our own admin UI using Rails-native affordances.

## Consequences

We recognize that making this choice may mean that we very quickly move on from
Administrate and just build out our own admin UI in fairly short order.
