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

---

Further discussion of the class diagram can be found in the three prototype files:

* [Prototype zero (abandoned)](./classes-prototype-zero.md)
* [Prototype A ("Code")](./classes-prototype-a.md)
* [Prototype B ("Data")](./classes-prototype-b.md)
