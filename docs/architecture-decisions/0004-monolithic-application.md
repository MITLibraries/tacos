# 4. Monolithic application

Date: 2023-07-20

## Status

Accepted

## Context

There are multiple ways to architect the application, or applications, to provide the type of functionality we are planning.

### Monolithic Architecture

One option is to build a monolithic Rails application that provides all of the planned functionality: an API to capture search terms and return structured data, the ability to analyze the search terms to determine what the structured data should be (i.e. is there a DOI in this term and if so we are confident it is for a specific item), as well as expert workflows to allow manual categorization of search terms.

### Services Architecture

Another option is to isolate each piece of functionality into separate services. Even within this approach, there are different ways to slice up the services to create a balance of additional application communication complexity with the benefit of single purpose applications.

#### Workflow Application and Categorization Application

This separates the functionality into two distinct applications.

##### Workflow Application

The Workflow Application handles staff user authentication and presents users with individual search terms that is must request from the Categorization Application. Users can write back to the Categorization Application via API when a category to assign a term to a Category. The Workflow Application focuses on authentication, presenting data from an API, and posting data to an API. It is likely users would also want to see analytics about searchterms so the Categorization Application would need to expose that via API as well as the Workflow Application stores no data at all.

##### Categorization Application

The Categorization Application exposes multiple APIs and has no user interface that is not an API. The API must restrict write access to APIs that can write categorizations, but the categorization lookup API is likely unrestricted (even though it would store the incoming searchterm in most cases). Whether we require authentication for applications to be able to lookup data is out of scope of this ADR, but will need to be considered.

Lookup API: accepts at minimum a searchterm and a string representing the calling application. Returns structured data with everythig we know about the provided search term.

CategorizeThis API

- GET: provides either a single term that needs categorization or possible a few terms. It is possible this may return objects or just raw terms depending on the needs of the Workflow Application.

- POST: writes back a category for the provided searchterm. It is possible this will be an object or array depending on what the Workflow Application requires.

Analytics API: likely a series of endpoints or a single endpoint with multiple features that will allow accept parameters and return appropriate analytics. The specific have not yet been determined.

## Decision

We will build this application initially as a monolithic application.

## Consequences

We will approach this as a pathfinder project, where we learn as we go and update our path and our plans dynamically as new information is uncovered.

In order to maximize our efficiency, we won't try to predict the "best" set of applications that will underpin this type of system before we start, and instead will reflect as we go and design the monolothic application modularly so that if a portion feels like it should spin off into its own external service, we will be able to interact via the same internal object in the monolith and no other objects will have to know anything has changed.

The internal API (objects) will remain the same, the objects themselves will start with internal logic that exposes the functionality we need, but transition to wrappers for external services, if appropriate, in the future. This is a new
practice for the team and we will need to take care in our choice of objects to ensure any future refactoring is as
smooth as possible.
