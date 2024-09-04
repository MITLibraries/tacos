# Prototype D ("Detectors have many Detections")

This prototype focuses attempts to only store positive detections, which seems valuable as most of our Terms have no `Detections` and other Prototypes stored "misses" in addition to "hits".

This comes at the cost of potentially storing more than one `Detection` for some Terms (i.e. if an ISSN and a JournalName match, we'll store 2 `Detection` records).

`Category` and `Categorization` are optional tables. They would serve as a sort of cache for the `calculateCategory()` method for a `Term`. This allows a `Term` to have multiple categories and would serve as as way to quickly report on what we know about the system rather than calculating everything on the fly. As each `Categorization` stores a confidence float, this should allow us to return to consuming systems how confident we are in each `Category` we return.

`Detector` is a place where we keep track of each algorithm we have coded and how confident we are in it's ability to predict a Category.

## Shared preface

The same color scheme is used for both prototypes:

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


  style Term fill:#000,stroke:#66c2a5,color:#66c2a5

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Categorization fill:#000,stroke:#8da0cb,color:#8da0cb
  style DetectionCategory fill:#000,stroke:#fc8d62,color:#fc8d62

  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb
```

### Order of operations

1. A term enters the system
2. If Categories exist, return the existing Categories.
3. If no Categories exist, run all Detectors and create Detection and Categorization records. If no Detections are made, we should consider Categorizing the Term as "Unknown" Category to allow for not running Detections again.
4. If new Detectors are created/adjusted. Categorizations should be deleted or expired in some way to allow for new Detections/Categorizations to be created.

### Category values

These are largely algorithmic in this model. We'd know what was detected from the Detections table and the `Term` or `Category` model would handle `Categorization` based on business logic we put in place. Example, having a DOI is high confidence for being a Specific Item.

Unsolved in this model: one Detector (so far) has `Categories` built into the `Detector` (SuggestedResources). These would need to be passed into the `calculateCategory()` method in some way to allow for appropriate `categorization`.

### Calculating the category scores

One interesting feature of DetectionCategory is that it stores the confidence of each algorithm to accurately predict a category. During validation, if a Detection made by an algorithm is confirmed, we can run `incrementConfidence()` whatever that ends up meaning. Similarly, if an Detection is validated as inaccurate, we can run `decrementConfidence()`.

> [!NOTE]
>DetectionCategory is a join table represented in Prototype B as `mapping`. This tries to nudge it towards a better name.

Some detectors are themselves non-binary in terms of prediction so they maintain a confidence level as well (namely JournalName detection is fairly weak compared to many other algorithms to date)

## Validations

