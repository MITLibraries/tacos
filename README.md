# TACOS: Tool for Analyzing and Categorization Of Searchterms

## Environment Variables

### Required

`LINKRESOLVER_BASEURL`: base url for our link resolver. `https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT` is probably the best value unless you are doing something interesting.

`ORIGINS`: comma-separated list of domains allowed to connect to (and thus query or contribute to) the application. Be sure to specify the port number if a connecting application is not using the standard ports (this applies mostly to local development). If not defined, no external connections will be permitted.

`UNPAYWALL_EMAIL`: email address to include in API call as required in their [documentation](https://unpaywall.org/products/api). Your personal email is appropriate for development. Deployed and for tests, use the timdex moira list email.

### Optional

`PLATFORM_NAME`: The value set is added to the header after the MIT Libraries logo. The logic and CSS for this comes from our theme gem.

## Documentation

[Architecture Decisions](docs/architecture-decisions/)

### Explanation/Overview

[Work Activity Analysis](docs/explanation/work-activity-analysis.md)

[Pattern Detection and Enhancement](docs/explanation/pattern_detection_and_enhancement.md)

### Reference

[Class Diagram](docs/reference/classes.md)
