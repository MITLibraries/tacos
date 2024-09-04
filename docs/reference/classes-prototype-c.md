# Prototype C ("Detections with confidence")

This prototype relies on fewer tables, with one record in each, and leans more heavily on behavior in code.

> [!WARN]
> The intent was to collapse Categorizations into Detections by moving booleans to floats, but this looses important
nuance from the original prototype A-minus it was based on.

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

  style Term fill:#000,stroke:#66c2a5,color:#66c2a5

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62

  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb
```

### Order of operations

1. A new `Term` is registered.
2. A `Detection` record for that `Term` is created (which allows repeat detection operations as TACOS gains new
   capabilities). Rather than storing a boolean, we store a float to represent how confident we are that the detection is able to be used for categorization. This approach feels flawed

### Category values

Not worked out as the model seems flawed and was abandoned after initial discussion.

### Calculating the category scores

Not worked out as the model seems flawed.

## Validations

Not worked out as the model seems flawed.
