# TACOS: Tool for Analyzing and Categorization Of Searchterms

## Local development

There is a `Makefile` that contains some useful command shortcuts for typical development tasks.

To see a current list of commands, run `make help`.

## Environment Variables

### Required

`LINKRESOLVER_BASEURL`: base url for our link resolver. `https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT` is probably the best value unless you are doing something interesting.

`ORIGINS`: comma-separated list of domains allowed to connect to (and thus query or contribute to) the application. Be sure to specify the port number if a connecting application is not using the standard ports (this applies mostly to local development). If not defined, no external connections will be permitted.

`UNPAYWALL_EMAIL`: email address to include in API call as required in their [documentation](https://unpaywall.org/products/api). Your personal email is appropriate for development. Deployed and for tests, use the timdex moira list email.

#### Authentication

Access to some of the config values below is limited. Please contact someone in the EngX team if you need help locating
them.

`BASE_URL`: The base url for the app. This is required for Omniauth config.
`FAKE_AUTH_CONFIG`: Switches Omniauth to developer mode when set to `true`. Fake auth is also enabled whenever the
app is started in the development environment, or if the app is a PR build (see `HEROKU_APP_NAME` under optional
variables).
`OP_HOST`: The OID provider hostname, required for authentication. (Do not include URL prefix.)
`OP_SECRET_KEY`: The secret key for the OID client.
`OP_CLIENT_ID`: The identifier for the OID client.
`OP_ISSUER`: The URL for the OIDC issuer. This can be found in the Touchstone OpenID metadata.

### Optional

`HEROKU_APP_NAME`: Used by the FakeAuthConfig module to determine whether an app is a PR build.
`PLATFORM_NAME`: The value set is added to the header after the MIT Libraries logo. The logic and CSS for this comes from our theme gem.

## Documentation

### Architecture Decisions

[Architecture Decisions](docs/architecture-decisions/)

### Explanation/Overview

[Work Activity Analysis](docs/explanation/work-activity-analysis.md)

[Pattern Detection and Enhancement](docs/explanation/pattern_detection_and_enhancement.md)

### Reference

`make docserver` will start a `yard` server using the RDoc comments from the codebase. RDoc in this application is a work-in-progress and should improve over time. As of this writing, the index page generated contains broken links to our markdown documentation, but they "files" navigation displays them properly.

> [!TIP]  
> Prior to running `make docserver` the first time, you must install the bundled gems for this application using either `bundle install` or `make install` (they both do the same thing!).

[Class Diagram](docs/reference/classes.md)
