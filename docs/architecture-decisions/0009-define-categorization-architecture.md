# 9. Define categorization architecture

Date: 2024-09-06

## Status

Accepted

## Context

We need to define the data model and workflow for TACOS and its users to place search terms into categories. This
includes a discussion about how those categories themselves will be represented (and what they are), and how existing
structures like Detectors contribute to that categorization activity.

A future decision, which should be considered now although not yet resolved, is how to enable users to validate these
categorization actions.

### The relationship between Terms, Detectors, and Categories

At a very high level, TACOS works according to the following flowchart:

```mermaid
flowchart LR

  Terms
  Detectors
  Categories

  Terms -- are evaluated by --> Detectors
  Detectors <-- are mapped to --> Categories
  Categories -- get linked with --> Terms
```

Search terms are received from a contributing system, and are evaluated by a set of Detectors which look for specific
patterns. Those Detectors are mapped to one or more Categories. As a result of these detections and their relationship
with each category, TACOS is able to calculate the strength of the link between each term and category.

The decision being documented here is how we achieve this relationship.

## Options considered

We evaluated multiple ways of implementing these relationships through prototyping, diagramming, and extensive
discussions. Each are documented here.

Each of the options described below uses the same graphic language:

* <font style="color:#66c2a5;border:4px solid #66c2a5;padding:2px;">Terms</font>, which flow in continuously with Search Events;
* A <font style="color:#fc8d62;border:1px solid #fc8d62;padding:2px;">knowledge graph</font>, which includes the categories, detectors, and relationships
  between the two which TACOS defines and maintains, and which is consulted during categorization; and
* The <font style="color:#8da0cb;border:1px dashed #8da0cb;padding:2px;">linkages between these terms and the graph</font>, which record which signals are
  detected in each term, and how those signals are interpreted to place the term into a category.

A simple way to describe the Categorization workflow would be to say that Categorization involves populating the blue
tables in the diagrams below.

### Prototype Zero

The simplest option to relate these elements is a single three-way join model, which would have pointers back to each
of the Term, Detector, and Category models.

```mermaid
classDiagram
  direction TB

  Term <-- Link
  Detector <-- Link
  Category <-- Link


  class Term
    Term: +Integer id
    Term: +String phrase

  class Category
    Category: +Integer id
    Category: +String name

  class Link:::styleClass
    Link: +Integer id
    Link: +Integer term_id
    Link: +Integer category_id
    Link: +Integer detector_id

  class Detector
    Detector: +Integer id
    Detector: +String name


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62

  style Link fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```

This option was rejected almost immediately because it does not allow for enough flexibility and would spawn far too
many extraneous records.

### Prototype A

The "A" prototype defined its linking records in two large models. The `Detection` model would record the relationship
between every `Term` and each detector in the application, with a field for each output. The `Categorization` model
would then build upon those detections, with a field for a calculated score according to each category. The category
with the highest score would finally be stored in the `Term` model for better performance.

The knowledge graph in this prototype would be comparatively sparse, with models for each lookup-style detector. The
relationships between detectors and categories would be defined directly within methods in the `Categorization` model.

```mermaid
classDiagram
  direction LR

  Term --< Detection: has many
  Detection <-- Categorization: based on
  Categorization --> SuggestedResource: looks up
  Detection --> SuggestedResource: looks up
  Detection --> Journal: looks up


  class Term
    Term: +Integer id
    Term: +String phrase
    Term: +Enum category

  class SuggestedResource
    SuggestedResource: +Integer id
    SuggestedResource: +String title
    SuggestedResource: +String url
    SuggestedResource: +String phrase
    SuggestedResource: +String fingerprint
    SuggestedResource: +Enum category
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
    Detection: +Boolean SuggestedResource
    Detection: initialize()
    Detection: setDetectionVersion()
    Detection: recordDetections()
    Detection: recordPatterns()
    Detection: recordJournals()
    Detection: recordSuggestedResource()

  class Categorization
    Categorization: +Integer id
    Categorization: +Integer detection_id
    Categorization: +Float information_score
    Categorization: +Float navigation_score
    Categorization: +Float transaction_score
    Categorization: initialize()
    Categorization: assign()
    Categorization: evaluate()
    Categorization: calculateAll()
    Categorization: calculateInformation()
    Categorization: calculateNavigation()
    Categorization: calculateTransaction()


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62
  style Journal fill:#000,stroke:#fc8d62,color:#fc8d62
  style SuggestedResource fill:#000,stroke:#fc8d62,color:#fc8d62

  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style Categorization fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```

A benefit of this prototype is that the `Detection` and `Categorization` models would be very intuitive to work with,
and allow for repeated classification as our application evolves. Querying these models from the controller level would
be very simple.

An area of uncertainty in this prototype was how to calculate confidence values and categorization scores for each
detector and category. We discussed multiple options for this question, but ultimately did not decide on a single
approach.

### Prototype B

The "B" prototype makes a different choice for recording both the knowledge graph, and the linkages to the terms flowing
into the application. The knowledge graph is more explicitly modeled in the database, with models for `Category`,
`Detectinator`, and the `DetectinatorCategory` model which maps between the two.

Because each of these records are now separate entries, this prototype further breaks up the large models for detection
and categorization outputs. The detection result is spread across multiple records in the `TermDetectinator` and
`TermSuggestedResource` models. The final categorization process is also recorded in multiple `TermCategory` records.

Because of this dispersion of information across multiple records, the methods needed to do the work end up being
defined in the `Term` model - shown here as methods like `evaluate_detectinators()` and `categorize()`.


```mermaid
classDiagram
  direction LR

  Term >-- TermDetectinator
  TermDetectinator --> Detectinator
  Category <-- DetectinatorCategory
  DetectinatorCategory --> Detectinator
  Term --> TermCategory
  TermCategory <-- Category
  SuggestedResource --> Category
  Term <-- TermSuggestedResource
  TermSuggestedResource --> SuggestedResource


  class Term
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

  class DetectinatorCategory
    DetectinatorCategory: +Integer detectinator_id
    DetectinatorCategory: +Integer category_id
    DetectinatorCategory: +Float confidence

  class TermCategory
    TermCategory: +Integer term_id
    TermCategory: +Integer category_id
    TermCategory: +Float confidence
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


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detectinator fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectinatorCategory fill:#000,stroke:#fc8d62,color:#fc8d62
  style SuggestedResource fill:#000,stroke:#fc8d62,color:#fc8d62

  style TermDetectinator fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style TermSuggestedResource fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style TermCategory fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```

One immediate advantage of this approach is that we have appropriate fields in the knowledge graph for storing
confidence values, which would be multiplied together to generate the final `score` value that is recorded in the
`TermCategory` records.

A drawback to this prototype is the duplication between the Detectinator and SuggestedResource models (remembering that
SuggestedResource is one of the application's detectors). While this set of models was meant to allow different
SuggestedResource records to be affiliated with different categories, that feature can be supported via code, rather
than relying on the data model.

### Prototype C

The "C" prototype was a further evolution of the "A" prototype, which attempted to combine all detection and 
categorization outputs in a single model. By changing the `Detection` table to storing floats rather than boolean
values, we attempted to reduce the number of models needed in the application.

```mermaid
classDiagram
  direction LR

  Term --< Detection: has many


  class Term
    Term: +Integer id
    Term: +String phrase
    Term: calculateCategory()

  class Detection
    Detection: +Integer id
    Detection: +Integer term_id
    Detection: +Integer detector_version
    Detection: +Float DOI
    Detection: +Float ISBN
    Detection: +Float ISSN
    Detection: +Float PMID
    Detection: +Float Journal
    Detection: +Float SuggestedResource
    Detection: initialize()
    Detection: setDetectionVersion()
    Detection: recordDetections()
    Detection: recordPatterns()
    Detection: recordJournals()
    Detection: recordSuggestedResource()


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```

Development of this prototype was halted fairly early, after realizing that the calculation of categorization values
would not necessarily be helped by combining models in this way.

### Prototype D

The "D" prototype was a further evolution of the "B" prototype, focused primarily on removing the separate structures
for SuggestedResources. There is still a knowledge graph spread across Detectors, Categories, and the mapping between
them. Detection and Categorization results are also spread across multiple link records.

Further refinements in this prototype are the inclusion of a `detector_version` value in the Detection model, and the
removal of a `user_id` field from the Categorization model (we are still debating the role of user-supplied 
categorizations, compared to the user-supplied validation of existing categorizations).

```mermaid
classDiagram
  direction LR

  Term "1" --> "1..*" Detection
  Term "1" --> "0..*" Categorization
  Detection "0..*" --> "1" Detector

  DetectionCategory "0..*" --> "1" Category

  Categorization "0..*" --> "1" Category

  Detector "1" --> "0..*" DetectionCategory


  class Term
    Term: +Integer id
    Term: +String phrase
    Term: calculateCategory()

  class Detection
    Detection: +Integer id
    Detection: +Integer term_id
    Detection: +Integer detector_id
    Detection: +Integer detector_version
    Detection: +Float confidence
    Detection: initialize()
    Detection: setDetectionVersion()
    Detection: recordDetections()
    Detection: recordPatterns()
    Detection: recordJournals()
    Detection: recordSuggestedResource()

  class Detector
    Detector: +Integer id
    Detector: +String name
    Detector: +Float confidence
    Detector: incrementConfidence()
    Detector: decrementConfidence()

  class Category
    Category: +Integer id
    Category: +String name

  class Categorization
    Categorization: +Integer category_id
    Categorization: +Integer term_id
    Categorization: +Float confidence

  class DetectionCategory
    DetectionCategory: +Integer id
    DetectionCategory: +Integer detector_id
    DetectionCategory: +Integer category_id
    DetectionCategory: +Float confidence
    DetectionCategory: incrementConfidence()
    DetectionCategory: decrementConfidence()


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectionCategory fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62

  style Categorization fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```

The significant benefit of this prototype is the removal of the SuggestedResource models, which leaves a more
straightforward data model which records only Detectors and Categories, without special consideration for any one
Detector.

## Decision

We will pursue the "D" prototype, with explicit models for the application's knowledge graph, and detection and
categorization outputs spread across linking records rather than concentrated in a single record.

## Consequences

There are still unknowns which we will confront while implementing this design. Among those are how the user permissions
model will intersect with these models, and how the controller and view layers will be defined to enable this to
function. Additionally, while we have discussed the process of calculating confidence values, it may be that writing
this implementation may reveal shortcomings we have not yet realized.

Our commitment at this stage, due to these uncertainties, is that we will further develop the "D" prototype by
attempting to implement it. Only time will tell whether we will successfully do so, or if we will need to change course.
