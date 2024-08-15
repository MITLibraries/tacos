# Prototype B ("Data")

This prototype relies on more models, more linking records, and as a result relies less on behavior in code.

## Shared preface

* <font style="color:#66c2a5">Terms</font>, which flow in continuously with Search Events;
* A <font style="color:#fc8d62">knowledge graph</font>, which includes the categories, detectors, and relationships
  between the two which TACOS defines and maintains, and which is consulted during categorization; and
* The <font style="color:#8da0cb">linkages between these terms and the graph</font>, which record which signals are
  detected in each term, and how those signals are interpreted to place the term into a category.

A simple way to describe the Categorization workflow would be to say that Categorization involves populating the blue
tables in the diagrams below.

## Categorization

```mermaid
classDiagram
  direction LR

  Term >-- TermDetectinator
  TermDetectinator --> Detectinator
  Category <-- Mapping
  Mapping --> Detectinator
  Term --> TermCategory
  TermCategory <-- Category
  SuggestedResource --> Category
  Term <-- TermSuggestedResource
  TermSuggestedResource --> SuggestedResource

  class Term:::primarytable
    Term: +Integer id
    Term: +String phrase
    Term: categorize()
    Term: evaluate_detectinators()
    Term: evaluate_identifiers()
    Term: evaluate_journals()
    Term: evaluate_suggested_resources()

  class TermDetectinator
    TermDetectinator: +Integer term_id
    TermDetectinator: +Integer detector_id
    TermDetectinator: +Boolean result

  class Detectinator
    Detectinator: +Integer id
    Detectinator: +String name
    Detectinator: +Float confidence

  class Category
    Category: +Integer id
    Category: +String name
    Category: +String note

  class Mapping
    Mapping: +Integer detectinator_id
    Mapping: +Integer category_id
    Mapping: +Float confidence

  class TermCategory
    TermCategory: +Integer term_id
    TermCategory: +Integer category_id
    TermCategory: +Integer user_id

  class SuggestedResource
    SuggestedResource: +Integer id
    SuggestedResource: +String title
    SuggestedResource: +String fingerprint
    SuggestedResource: +URL url
    SuggestedResource: +Integer category_id

  class TermSuggestedResource
    TermSuggestedResource: +Integer term_id
    TermSuggestedResource: +Integer suggested_resource_id
    TermSuggestedResource: +Boolean result

  style Term fill:#000,stroke:#66c2a5,color:#66c2a5

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detectinator fill:#000,stroke:#fc8d62,color:#fc8d62
  style Mapping fill:#000,stroke:#fc8d62,color:#fc8d62
  style SuggestedResource fill:#000,stroke:#fc8d62,color:#fc8d62

  style TermDetectinator fill:#000,stroke:#8da0cb,color:#8da0cb
  style TermSuggestedResource fill:#000,stroke:#8da0cb,color:#8da0cb
  style TermCategory fill:#000,stroke:#8da0cb,color:#8da0cb
```

### The "knowledge graph"

The relationship between Detectors and Categories would be generally set ahead of time. Detectors produce a boolean
output in the cleanest case - they either detect a signal or they do not. Relatedly, detectors have an influence over
whether a given Category is relevant or not:

* If the Detector for a DOI pattern returns `true`, then this influences the `transactional` Category to a significant
  degree.
* However, the Detector for a DOI pattern does almost nothing to influence the `navigational` Category.
* If Categorization is a zero-sum activity, however, the DOI pattern detector would _exclusively_ claim a Term for the
  `transactional` Category - so it would effectively rule out the other two Categories.

The exception to this Detector rule is the SuggestedResource detector - which has variability in its records. Some
SuggestedResources are in each of the three Categories, so there is a more complicated decision-making algorithm, and
thus a different set of database tables.

### Category scores

At the moment, category scores are intended to be calculated by combining the confidence values for both the detector
and the DetectorCategory link (as well as the result of the detection pass, if negative results are stored). See the
workflow document for this prototype for an explanation of this math. I've begun an implementation of this approach
in the `Term.categorize` method in this prototype, but this is not finished.

### Order of operations

The linkages between these tables are filled in at different moments.

The Detector-Category linkage is maintained as either set of resources evolves over time, and on a relatively slow
cadence. Operationally, the links which matter are made as new Terms flow into TACOS.

1. A new Term is recorded in the system.
2. That Term is compared with each Detector, and any positive responses are recorded. Negative responses may be
   discarded, or recorded for the sake of completeness (to confirm that the link was tested). These outcomes are stored
   as several records across the TermDetectinator and TermSuggestedResource tables.
3. Those detection records are then used to perform the Categorization work, comparing the confidence values of each
   Detectinator and Mapping. The responses are then used to perform the Categorization work, which results in records
   being created in the TermCategory table.

### Questions

* The application defines a `Detector` module/namespace. Ideally I want a `Detector` class for the records of our
  various detectors, but I'm not sure this is possible (or I haven't figured out how). If `Detector` is not possible,
  should we use an un-namespaced option like `Detectinator`, or instead go with something like `Detector::Detector` or
  `Detector::Base` ?
  * One of the reasons why I went with an un-namespaced class here is to make defining link tables easier
    (`Term_Detectinator` instead of `Term_DetectorBase`)
* The `TermDetectinator` table records the results of our suite of detectors in response to a given term. Should we
  record only positive results, or should we also record negative results?
  * The `Mappings` table (which should be named `CategoryDetectinator`) has a similar question - whether we should
    record no-confidence mappings (for example, a DOI detection would have 0 confidence toward a navigational
    categorization)

## Validations

Valdations might get thorny in this model, because the results we are validating are spread across multiple records in
the same class. For example, a single term record like `Collins HK. When listening is spoken. doi: 10.1016/j.copsyc.2022.101402. PMID: 35841883.`
would result in multiple records in the `TermDetectinator` table, each of which would be subject to validation. As a
result it might make sense to embed the validation throughout the data model, rather than in a separate field?

```mermaid
classDiagram
  direction LR

  Term >-- TermDetectinator
  TermDetectinator --> Detectinator
  Category <-- Mapping
  Mapping --> Detectinator
  Term --> TermCategory
  TermCategory <-- Category
  SuggestedResource --> Category
  Term <-- TermSuggestedResource
  TermSuggestedResource --> SuggestedResource
  Validation <-- ValidTermDetectinator
  ValidTermDetectinator --> TermDetectinator
  Validation <-- ValidTermCategory
  ValidTermCategory --> TermCategory
  Validation <-- ValidTermSuggestedResource
  ValidTermSuggestedResource --> TermSuggestedResource

  class Term:::primarytable
    Term: +Integer id
    Term: +String phrase
    Term: categorize()
    Term: evaluate_detectinators()
    Term: evaluate_identifiers()
    Term: evaluate_journals()
    Term: evaluate_suggested_resources()

  class TermDetectinator
    TermDetectinator: +Integer term_id
    TermDetectinator: +Integer detector_id
    TermDetectinator: +Boolean result

  class Detectinator
    Detectinator: +Integer id
    Detectinator: +String name
    Detectinator: +Float confidence

  class Category
    Category: +Integer id
    Category: +String name
    Category: +String note

  class Mapping
    Mapping: +Integer detectinator_id
    Mapping: +Integer category_id
    Mapping: +Float confidence

  class TermCategory
    TermCategory: +Integer term_id
    TermCategory: +Integer category_id
    TermCategory: +Integer user_id

  class SuggestedResource
    SuggestedResource: +Integer id
    SuggestedResource: +String title
    SuggestedResource: +String fingerprint
    SuggestedResource: +URL url
    SuggestedResource: +Integer category_id

  class TermSuggestedResource
    TermSuggestedResource: +Integer term_id
    TermSuggestedResource: +Integer suggested_resource_id
    TermSuggestedResource: +Boolean result

  class Validation
    Validation: +Integer id
    Validation: +Integer user_id

  class ValidTermCategory
    ValidTermCategory: +Integer validation_id
    ValidTermCategory: +Integer termcategory_id
    ValidTermCategory: +Boolean valid

  class ValidTermDetectinator
    ValidTermDetectinator: +Integer validation_id
    ValidTermDetectinator: +Integer termdetectinator_id
    ValidTermDetectinator: +Boolean valid

  class ValidTermSuggestedResource
    ValidTermSuggestedResource: +Integer validation_id
    ValidTermSuggestedResource: +Integer termsuggestedresource_id
    ValidTermSuggestedResource: +Boolean valid


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detectinator fill:#000,stroke:#fc8d62,color:#fc8d62
  style Mapping fill:#000,stroke:#fc8d62,color:#fc8d62
  style SuggestedResource fill:#000,stroke:#fc8d62,color:#fc8d62

  style TermDetectinator fill:#000,stroke:#8da0cb,color:#8da0cb
  style TermSuggestedResource fill:#000,stroke:#8da0cb,color:#8da0cb
  style TermCategory fill:#000,stroke:#8da0cb,color:#8da0cb

  style Validation fill:#000,stroke:#ffd407,color:#ffd407
  style ValidTermCategory fill:#000,stroke:#ffd407,color:#ffd407
  style ValidTermDetectinator fill:#000,stroke:#ffd407,color:#ffd407
  style ValidTermSuggestedResource fill:#000,stroke:#ffd407,color:#ffd407
```

This is an extension of the original class diagram, adding the validation data model in yellow. The thesis of the model
is that every decision made during Categorization is subject to review during Validation, potentially by multiple
reviewers.

If validation is only performed once, we don't need any of the yellow tables, and we instead could just add a boolean
`valid` flag to each categorization table.