# Modeling categorization

## Initial proposal

```mermaid
classDiagram
  direction TB
  
  AdminUser --> User : Is a Type of
  Term --> SearchEvent : has many

  User --> Categorization : Creates a
  User --> Category : Proposes a
  Categorization --> Term : Includes a
  Categorization --> Category : Includes a

  class Term
    Term: id
    Term: +String phrase
    Term: calculate_certainty(term)
    Term: list_unique_terms_with_counts()
    Term: uncategorized_term()
    Term: categorized_term()

  class SearchEvent
    SearchEvent: +Integer id
    SearchEvent: +Integer term_id
    SearchEvent: +String source
    SearchEvent: +Timestamp timestamp

  class User
    User: +String kerbid
    User: +Boolean admin
    User: categorize_term(term, category, notes (optional))
    User: propose_category(name, description, reason)
    User: view_next_term()
  
  class AdminUser
    AdminUser: approve_category()
    AdminUser: create_category()
    AdminUser: upload_batch()
    AdminUser: view_proposed_categories()

  class Category
    Category: +String name
    Category: +String reason
    Category: +Boolean approved
    Category: +Text description

  class Categorization
    Categorization: id
    Categorization: +Integer category_id
    Categorization: +Integer term_id
    Categorization: +Integer user_id
    Categorization: +Text notes

  class DetectorCategorization
    DetectorCategorization: +Integer categorization_id
    DetectorCategorization: +Integer detector_id
    DetectorCategorization: +Float confidence # maybe this is a wrap up of multiple Detector confidences (calculated value)

  class Detector
    Detector: +Integer id
    Detector: +String name
    Detector: +Float confidence # determined by validation yes/no votes

  class Report
    Report: percent_categorized()
    Report: category_history()
```
---

## Conceptual diagram

There are three basic models which we are attempting to relate to each other:
Terms, Detectors, and Categories. The relationship looks like this:

```mermaid
classDiagram
  direction TB

  Term --> Category: are placed into
  Detector --> Term: get applied to
  Category --> Detector: are informed by

  class Term
    Term: +Integer id
    Term: +String phrase

  class Category
    Category: +Integer id
    Category: +String name

  class Detector
    Detector: +Integer id
    Detector: +String name

```

Some sample data in each table might be:

### Terms

| id | phrase                                |
|----|---------------------------------------|
| 1  | web of science                        |
| 2  | pitchbook                             |
| 3  | vaibbhav taraate                      |
| 4  | doi.org/10.1080/17460441.2022.2084607 |
---

We have received more than 40,000 unique search terms from the Bento system in
the first three months of TACOS operation.

### Categories

| id | name          | note                                                                                      |
|----|---------------|-------------------------------------------------------------------------------------------|
| 1  | Transactional | The user wants to complete an _action_ (i.e. to receive an item)                          |
| 2  | Navigational  | The user wants to reach a _place_ which might be a web page, or perhaps talk to a person. |
| 3  | Informational | The user wants _information_ about an idea or concept.                                    |

Thus far, we have only focused on these three categories of search intent. It
should be noted that the SEO literature references additional categories, such
as "commercial" or "conversational".

Additionally, some of these categories may be sub-divided. Transactional
searches might be looking for a book, a journal article, or a thesis.
Navigational searches might be satisfied by visiting the desired webpage, or
contacting a liaison.

### Detectors

| id | name               | note            |
|----|--------------------|-----------------|
| 1  | DOI                | Regex detection |
| 2  | ISBN               | Regex detection |
| 3  | ISSN               | Regex detection |
| 4  | PMID               | Regex detection |
| 5  | Journal name       | Term lookup     |
| 6  | Suggested resource | Term lookup     |


## One central join table
```mermaid
classDiagram
  direction TB

  Term --> Link
  Category --> Link
  Detector --> Link

  class Term
    Term: +Integer id
    Term: +String phrase

  class Category
    Category: +Integer id
    Category: +String name

  class Link
    Link: +Integer
    Link: +Integer term_id
    Link: +Integer category_id
    Link: +Integer detector_id

  class Detector
    Detector: +Integer id
    Detector: +String name
```
---
# Sets of two-way join tables

```mermaid
classDiagram
  direction LR

  Term >-- TermDetector
  TermDetector --> Detector
  Category <-- DetectorCategory
  DetectorCategory --> Detector
  Term --> TermCategory
  TermCategory <-- Category
  SuggestedResource --> Category
  Term <-- TermSuggestedResource
  TermSuggestedResource --> SuggestedResource

  class Term:::primarytable
    Term: +Integer id
    Term: +String phrase

  class TermDetector
    TermDetector: +Integer term_id
    TermDetector: +Integer detector_id
    TermDetector: +Boolean result

  class Detector
    Detector: +Integer id
    Detector: +String name
    Detector: hasMatch()

  class Category
    Category: +Integer id
    Category: +String name
    Category: +String note

  class DetectorCategory
    DetectorCategory: +Integer detector_id
    DetectorCategory: +Integer category_id

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

  style Category fill:#000,stroke:#ffd407,color:#ffd407
  style Detector fill:#000,stroke:#ffd407,color:#ffd407
  style Term fill:#000,stroke:#ffd407,color:#ffd407
```

The principle resources are Terms, Categories, and Detectors. Terms flow in
continuously. Detectors are less fluid, but might still be expected to change as
we improve our operations. Categories are the slowest changing.

The relationship between Detectors and Categories would be generally set ahead
of time. Detectors produce a boolean output in the cleanest case - they either
detect a signal, or they do not. Relatedly, detectors have an influence over
whether a given Category is relevant, or not:

* If the Detector for a DOI pattern returns `true`, then this influences the
  `transactional` Category to a significant degree.
* However, the Detector for a DOI pattern does almost nothing to influence the
  `navigational` Category.
* If Categorization is a zero-sum activity, however, the DOI pattern detector
  would _exclusively_ claim a Term for the `transactional` Category - so it
  would effectively rule out the other two Categories.

The exception to this Detector rule is the SuggestedResource detector - which
has variability in its records. Some SuggestedResources are in each of the three
Categories, so there is a more complicated decision-making algorithm, and thus
a different set of database tables.

## Order of operations

The linkages between these tables are filled in at different moments.

The Detector-Category linkage is determined as either set of resource is made,
and on a relatively slow cadence. Operationally, the links which matter are made
as new Terms flow into TACOS.

1. A new Term is recorded in the system.
2. That Term is compared with each Detector, and any positive responses are
   recorded. Negative responses may be discarded, or recorded for the sake of
   completeness (to confirm that the link was tested).
3. Those Term-Detector responses are then used to perform the Categorization
   work, which results in records being created in the TermCategory table.

---

# Less "pure" implementation
```mermaid
classDiagram

  Term >-- Detection: has many
  Detection >-- Categorization: based on
  Category >-- SuggestedResource: belongs to
  Categorization --> SuggestedResource: looks up
  Detection --> SuggestedResource: looks up
  Detection --> Journal: looks up
  Categorization >-- Validation: subject to

  class Term
    Term: +Integer id
    Term: +String phrase

  class SuggestedResource
    SuggestedResource: +Integer id
    SuggestedResource: +String title
    SuggestedResource: +String url
    SuggestedResource: +String phrase
    SuggestedResource: +String fingerprint
    SuggestedResource: +Integer category_id
    SuggestedResource: calculateFingerprint()

  class Journal
    Journal: +Integer id
    Journal: +String title

  class Detection
    Detection: +Integer id
    Detection: +Integer term_id
    Detection: +Integer detector_version
    Detection: +Boolean DOI
    Detection: +Boolean ISBN
    Detection: +Boolean ISSN
    Detection: +Boolean PMID
    Detection: +Boolean Journal
    Detection: +Integer journal_id
    Detection: +Boolean SuggestedResource
    Detection: +Integer suggested_resource_id
    Detection: +Boolean LCSH
    Detection: +Boolean WebsitePageTitle
    Detection: hasDOI()
    Detection: hasISBN()
    Detection: hasISSN()
    Detection: hasPMID()
    Detection: hasJournal()
    Detection: hasSuggestedResource()
    Detection: hasLCSH()
    Detection: hasWebsitePageTitle()

  class Detector
    Detector: +Integer id
    Detector: +String name
    Detector: +Float DOI_Confidence

  class Category
    Category: +Integer id
    Category: +String name

  class Categorization
    Categorization: +Integer id
    Categorization: +Integer detection_id
    Categorization: +Float transaction_score
    Categorization: +Float information_score
    Categorization: +Float navigation_score
    Categorization: evaluateTransaction()
    Categorization: evaluateInformation()
    Categorization: evaluateNavigation()

  class Validation
    Validation: +Integer id
    Validation: +Integer categorization_id
    Validation: +Boolean approve_transaction
    Validation: +Boolean approve_information
    Validation: +Boolean approve_navigation
    Validation: +Boolean approve_doi
    Validation: +Boolean approve_isbn
    Validation: +Boolean approve_issn
    Validation: +Boolean approve_pmid
    Validation: +Boolean approve_journal
    Validation: +Boolean approve_suggested_resource
    Validation: +Boolean approve_lcsh
    Validation: +Boolean approve_webpage

  style Term fill:#000,stroke:#ffd407,color:#ffd407
  style Detector fill:#000,stroke:#ffd407,color:#ffd407
  style Category fill:#000,stroke:#ffd407,color:#ffd407
```
This makes the order of operation a bit more explicit:

1. A new Term is registered.
2. The Detection table entry for that Term is populated (which allows repeat
   Detection passes as the detector models change).
3. The output of various Detection passes (either the most recent for each term,
   or all detections over time) are processed via code to generate scores for
   each potential category.