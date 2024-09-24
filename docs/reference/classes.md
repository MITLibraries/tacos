# Modeling categorization

The application includes the following entities, most of which an be broken into one of the following three areas:

* <font style="color:#66c2a5;border:4px solid #66c2a5;padding:2px;">Search activity</font>, which flow in continuously with Terms and Search Events;
* A <font style="color:#fc8d62;border:1px solid #fc8d62;padding:2px;">knowledge graph</font>, which includes the categories, detectors, and relationships
  between the two which TACOS defines and maintains, and which is consulted during categorization; and
* The <font style="color:#8da0cb;border:1px dashed #8da0cb;padding:2px;">linkages between these search terms and the graph</font>, which record which signals are
  detected in each term, and how those signals are interpreted to place the term into a category.

```mermaid
classDiagram
  direction LR
  
  Term --> SearchEvent : has many

  Term "1" --> "1..*" Detection
  Term "1" --> "0..*" Categorization
  Detection "0..*" --> "1" Detector

  DetectorCategory "0..*" --> "1" Category

  Categorization "0..*" --> "1" Category

  Detector "1" --> "0..*" DetectorCategory

  class User
    User: +String uid
    User: +String email
    User: +Boolean admin

  class Term
    Term: id
    Term: +String phrase
    Term: combinedScores()
    Term: recordDetections()

  class SearchEvent
    SearchEvent: +Integer id
    SearchEvent: +Integer term_id
    SearchEvent: +String source
    SearchEvent: +Timestamp created_at
    SearchEvent: single_month()

  class Detection
    Detection: +Integer id
    Detection: +Integer term_id
    Detection: +Integer detector_id
    Detection: +String detector_version
    Detection: current()
    Detection: for_detector()
    Detection: for_term()
    Detection: scores()

  class Detector
    Detector: +Integer id
    Detector: +String name

  class Category
    Category: +Integer id
    Category: +String name

  class Categorization
    Categorization: +Integer category_id
    Categorization: +Integer term_id
    Categorization: +Float confidence
    Categorization: +String detector_version
    Categorization: current()

  class DetectorCategory
    DetectorCategory: +Integer id
    DetectorCategory: +Integer detector_id
    DetectorCategory: +Integer category_id
    DetectorCategory: +Float confidence
    DetectorCategory: incrementConfidence()
    DetectorCategory: decrementConfidence()

  class DetectorJournal
    DetectorJournal: full_term_match()
    DetectorJournal: partial_term_match()
    DetectorJournal: record()

  class DetectorStandardIdentifier
    DetectorStandardIdentifier: record()

  class DetectorSuggestedResource
    DetectorSuggestedResource: bulk_replace()
    DetectorSuggestedResource: calculate_fingerprint()
    DetectorSuggestedResource: full_term_match()
    DetectorSuggestedResource: record()
    DetectorSuggestedResource: update_fingerprint()


  namespace SearchActivity{
    class Term
    class SearchEvent
  }

  namespace KnowledgeGraph{
    class Detectors
    class DetectorCategory
    class Category
  }

  namespace Detectors {
    class Detector
    class DetectorJournal["Detector::Journal"]
    class DetectorStandardIdentifier["Detector::StandardIdentifiers"]
    class DetectorSuggestedResource["Detector::SuggestedResource"]
  }

  style SearchEvent fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;
  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectorCategory fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectorJournal fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectorStandardIdentifier fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectorSuggestedResource fill:#000,stroke:#fc8d62,color:#fc8d62

  style Categorization fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```
