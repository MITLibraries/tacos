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
