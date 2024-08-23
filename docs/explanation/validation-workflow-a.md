# The categorization and validation workflow

This document describes the workflow for categorizing, and then validating, how
a given term has been processed by TACOS.

## Preparation

Pick what record we're working with. In production, this would happen as new
terms are recorded, but for now we're working with a randomly chosen example.

```ruby
t = Term.all.sample
```

## Pass the term through our suite of detectors

This assumes that all of our detection algorithms are integrated with the
Detector model, which creates a record of their output for processing during the
Categorization phase.

```ruby
d = Detection.new(t)
d.save
```

To this point the Detection model only records activations by each detection, as
boolean values. Future development might add more details, such as which records
are matched, or what external lookups return. It might also be relevant to note
whether multiple patterns are found.

```ruby
irb(main):013> d
=> 
#<Detection:0x0000000122606878
 id: 5,
 term_id: 53558,
 detection_version: 1,
 doi: false,
 isbn: false,
 issn: false,
 pmid: false,
 journal: false,
 suggestedresource: false,
 created_at: Fri, 23 Aug 2024 13:38:21.631333000 UTC +00:00,
 updated_at: Fri, 23 Aug 2024 13:38:21.631333000 UTC +00:00>
```

In this example, none of the detectors found anything.

The `detection_version` value in these records gets stored in ENV, and
incremented as our detection algorithms change. This helps identify whether a
Detection is outdated and needs to be refreshed.

## Generate the Categorization values based on these detections

```ruby
c = Categorization.new(d)
c.save
```

The creation of the record includes the calculation of scores for each of the
three categories. To this point, the logic is exceedingly simple, but this can
be made more nuanced with time.

```ruby
irb(main):019> c
=> 
#<Categorization:0x0000000117c3a920
 id: 2,
 detection_id: 5,
 transaction_score: 0.0,
 information_score: 0.0,
 navigation_score: 0.0,
 created_at: Fri, 23 Aug 2024 13:43:17.640485000 UTC +00:00,
 updated_at: Fri, 23 Aug 2024 13:43:17.640485000 UTC +00:00>
```

These scores are used by the `evaluate` method to assign the term to a category,
if relevant. Because none of the detectors fired in the previous step, all of
the category scores are 0.0 and the term will be placed in the "unknown"
category.

```ruby
t.category = c.evaluate
t.save
```

There is also an `assign` method at the moment, which combines the above steps.
This may not make sense in production, however.

The result of the Categorization workflow is that the original Term record now
has been placed in a category:

```ruby
irb(main):008> t
=> 
#<Term:0x00000001073c56d8
 id: 53558,
 phrase: "Darfur: A Short History of a Long War ",
 created_at: Tue, 20 Aug 2024 13:26:23.628215000 UTC +00:00,
 updated_at: Tue, 20 Aug 2024 13:26:23.628215000 UTC +00:00,
 category: "unknown">
```

From end to end, the code to categorize all untouched term records is then this:

```ruby
Term.where("category is null").each { |t|
    d = Detection.new(t)
    d.save
    c = Categorization.new(d)
    c.assign
}
```

## Validation

Humans will be asked to inspect the outcomes of the previous steps, and provide
feedback about whether any decisions were made incorrectly.

```ruby
v = Validation.new(c)
v.save
```

Validation records have a boolean flag for each decision which went into the
process thus far:

```ruby
irb(main):011> v
=> 
#<Validation:0x0000000116296870
 id: 1,
 categorization_id: 3,
 valid_category: nil,
 valid_transaction: nil,
 valid_information: nil,
 valid_navigation: nil,
 valid_doi: nil,
 valid_isbn: nil,
 valid_issn: nil,
 valid_pmid: nil,
 valid_journal: nil,
 valid_suggested_resource: nil,
 flag_term: nil,
 created_at: Fri, 23 Aug 2024 14:57:09.627620000 UTC +00:00,
 updated_at: Fri, 23 Aug 2024 14:57:09.627620000 UTC +00:00>
```

This includes a flag for the final result, each component score, each individual
detection, and a final flag that indicates the Term itself needs review. The
intent of this final flag is for the case where a search term is somehow
problematic and needs to be expunged.

There are no methods yet on this model, because all values are meant to be set
individually via the web interface.

There is not - yet - a notes field on the Validation model, but this is
something that we've discussed in case the validator has more detailed feedback
about some part of the decision-making that is being reviewed.

