# Prototype Zero

This was the simplest possible way to join the three basic resources (Terms, Detectors, and Categories).

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

This was not developed further, because the other two prototypes (A and B) immediately seemed more capable than this
approach. Having a single join table link all three resources is a recipe for duplicate and inconsistent data that is
hard to work with.

It is included here only for the sake of completeness.
