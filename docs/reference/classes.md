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

  DetectionCategory "0..*" --> "1" Category

  Categorization "0..*" --> "1" Category

  Detector "1" --> "0..*" DetectionCategory

  class User
    User: +String uid
    User: +String email
    User: +Boolean admin
  
  class Term
    Term: id
    Term: +String phrase
    Term: calculateCategory()
    Term: recordDetections()
    Term: recordPatterns()
    Term: recordJouranls()
    Term: recordSuggestedResources()

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

  style SearchEvent fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;
  style Term fill:#000,stroke:#66c2a5,color:#66c2a5,stroke-width:4px;

  style Category fill:#000,stroke:#fc8d62,color:#fc8d62
  style DetectionCategory fill:#000,stroke:#fc8d62,color:#fc8d62
  style Detector fill:#000,stroke:#fc8d62,color:#fc8d62

  style Categorization fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
  style Detection fill:#000,stroke:#8da0cb,color:#8da0cb,stroke-dasharray: 3 5;
```
