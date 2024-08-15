# The categorization and validation workflow

Start with a term record somehow...

```ruby
t = Term.all.sample
```

All the methods in this prototype are part of the Term model. Because the data model is so distributd across so many
tables, the Term model feels like it could be the most stable place for both detection recording and categorization.
There is a Validation model, so that workflow be built out there.

## Detections

Detection results are created and stored via the `evaluate_*` methods. Calling these methods multiple times will result
in duplicate records.

Only positive detections are stored in this prototype. Doing this makes categorization easier, but might hamper our
visibility into system behavior.

```ruby
# This calls each of the sub-methods in turn for identifiers, journals, and suggested resources.
t.evalute_detectinators
```

### The "detection_version" environment variable

The other prototype introduces an environment variable `DETECTION_VERSION` in order to recognize that TACOS'
capabilities will likely expand over time.

While such a variable might be useful for this prototype, we should recognize that key aspects of the application's
behavior are recorded only in database records - such as the linkages between detectors and categories. Because those
records can change so easily, we will need to consider carefully how to implement a versioning feature to capture how
system performance changes over time.

## Categorization

At this point, the positive outputs of our detectors has been recorded. The next step is to perform the categorizations.

This is not functional in this prototype, but the `categorize` method indicates a possible direction:

```ruby
irb(main):051> t.categorize

 INFO -- : This method will calculate the confidence scores for this term.
 INFO -- : Transactional-PMID: 0.95 * 0.95 = 0.9025
 INFO -- : Transactional-DOI: 0.95 * 0.95 = 0.9025
```

In this example, both the DOI and PMID detectors returned positive results. Each of these detectors are joined to the
"Transactional" category, so the method multiplies the confidence values of the detector by the confidence value of the
mapping, and generates a score. These scores would be added together, resulting in the following scores for each
category:

| Category      | CategoryScore |
|---------------|---------------|
| Informational | 0.0           |
| Navigational  | 0.0           |
| Transactional | ~1.8          |

In SQL terms, the sort of querying logic that this method would need would be something like:

```SQL
SELECT c.name AS Category, SUM(d.confidence * dc.confidence) AS CategoryScore
FROM terms t
LEFT OUTER JOIN TermDetectinator td ON t.id = td.term_id
LEFT OUTER JOIN detectors d ON td.detectinator_id = d.id
LEFT OUTER JOIN Mapping dc ON d.id = dc.detectinator_id
LEFT OUTER JOIN categories c ON dc.category_id = c.id
WHERE t.id = 4
GROUP BY c.id
```

_Note: if we end up storing negative results from the detection workflow, the equation above would need to be expanded
to include the detector result as an integer: `d.confidence * dc.confidence * td.result`. This would end up dropping
the negative results and associated confidence values._

For convenience, the winning category could be stored back into the `Term` model, similarly to the other prototype. The
category scores would be stored as values in the TermCategory table.

If we ever ask colleagues to manually categorize Term records - which is a fundamental break with these prototypes'
assumptions - taht TermCategory table would need to have an optional field to record who performed that categorization.

## Validation

Validation has been modeled in the classes prototype, but not executed in code.

```ruby
v = Validation.new(t)

v.report
# This would return a list of all linked recorects for the given Term.
```

This would end up querying all records from the validatable tables (TermDetectinator, TermCategory, and
TermSuggestedResource), and list everything that is returned. Every such record would spawn a related record in the
validation tables (ValidTermDetectinator, ValidTermCategory, and ValidTermSuggestedResource), with a boolean value to
indicate whether the detection is confirmed or invalidated.

While there is a discussion elsewhere in this prototype about whether to store only positive or all results from the
Detection workflow, in terms of Validation I think it makes the most sense to store both types.
