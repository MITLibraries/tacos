# TACOS: Tool for Analyzing and Categorization Of Searchterms

## Local development

There is a `Makefile` that contains some useful command shortcuts for typical development tasks.

To see a current list of commands, run `make help`.

### Development containers (aka devcontainers)

This repository provides [devcontainers](https://containers.dev). Rather than taking the time to configure your local
environment, consider using the provided devcontainers. You can still use your prefered code editors as if you were
working locally, but all execution of code will happen in containers in a way that will be consistent across all
developers using these containers.

#### Visual Studio Code

[Visual Studio Code can detect and manage devcontainers](https://code.visualstudio.com/docs/devcontainers/containers)
for you. It can build and reopen the code in the container and then the terminal within Visual Studio Code will execute
commands in the container. The first time you start the container, it is a bit slow but subsequent launches are fairly
quick.

This requires a functional Docker environment and the [Visual Studio Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

Note: when Visual Studio Code reopens in the container, it does not automaticaly launch the server. Instead, you use the
terminal within Visual Studio Code to run the same commands you would in a local environment, such as `bin/rails s` or
`bin/rails test`. In this repo, we also have a series of command shortcuts you can see via `make`.

#### Non-Visual Studio Code

If you prefer an editor other than Visual Studio Code, you can manage [Dev Containers from the CLI](https://containers.dev/supporting#devcontainer-cli) or look to see if your chosen editor may have direct support for Dev Containers.

[DevPod](https://github.com/loft-sh/devpod) is also something to consider. It provides a VScode-via-web-browser-in-a-box
as well as allowing you to use whatever editor you want and only using DevPod to start/stop the containers and run your
terminals. With this approach you could use your local editor, and the DevPod managed Dev Container for everything else.

### Generating cassettes for tests

We use [VCR](https://github.com/vcr/vcr) to record transactions with remote systems for testing. This includes the rake
task for reloading Detector::SuggestedResource records, which do not yet have a standard provider. For the initial
feature development, we have used a Lando environment with the following definition:

```yml
name: static
recipe: lamp
config:
  webroot: .
```

We use Lando here because its use in our WordPress environment. However, any static local webserver will work.

If you need to regenerate these cassettes, the following procedure should be sufficient:

1. Use the configuration above to ensure the needed files are visible at `http://static.lndo.site/filename.ext` (i.e.,
run `lando start` in `tacos/test/fixtures/files`). If you are using a server other than Lando, configure it such that
`tacos/test/fixtures/files` is the root directory, then start the server.
2. Delete any existing cassette files which need to be regenerated.
3. Run the test(s).
4. Commit the resulting files along with your other work.

## Environment Variables

### Required

`DETECTOR_VERSION`: a string that gets incremented as the application's detectors develop. When any detector's behavior
changes, this is the signal which indicates that terms need to be re-evaluated.

`LINKRESOLVER_BASEURL`: base url for our link resolver. `https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT` is probably the best value unless you are doing something interesting.

`ORIGINS`: comma-separated list of domains allowed to connect to (and thus query or contribute to) the application. Be sure to specify the port number if a connecting application is not using the standard ports (this applies mostly to local development). If not defined, no external connections will be permitted.

`TACOS_EMAIL`: email address to include in API calls or contact information. Currently used in API calls to [Unpaywall](https://unpaywall.org/products/api) and [OpenLibrary](https://openlibrary.org/developers/api). Your personal email is appropriate for development. Deployed and for tests, use the tacos-help moira list email.

### Optional

`LIBKEY_KEY`: LibKey API key. Required if `LIBKEY_DOI` or `LIBKEY_PMID` are set.
`LIBKEY_ID`: LibKey Library ID. Required if `LIBKEY_DOI` or `LIBKEY_PMID` are set.
`LIBKEY_DOI`: If set, use LibKey for DOI metadata lookups. If not set, Unpaywall is used.
`LIBKEY_PMID`: If set, use LibKey for PMID metadata lookups. If not set, NCBI Entrez is used.

`PLATFORM_NAME`: The value set is added to the header after the MIT Libraries logo. The logic and CSS for this comes
from our theme gem.

Scout settings can be controlled via `config/scout_apm.yml` or ENV. ENV overrides config.
Lots more [Scout settings](https://scoutapm.com/docs/ruby/configuration#environment-variables) available.
`SCOUT_KEY`: ScoutAPM key. Do not set in dev or test.
`SCOUT_LOG_LEVEL`: defaults to INFO which is probably fine. Controls verboseness of Scout logs
`SCOUT_NAME`: set a unique name per deployed tier to avoid confusion.

`SENTRY_DSN`: The Sentry-provided key to enable exception logging. Sentry integration is skipped if not present.
`SENTRY_ENV`: Sentry environment for the application. Defaults to 'unknown' if unset.

### Authentication

#### Required in all environments

Access to some of the config values below is limited. Please contact someone in the EngX team if you need help locating
them.

`BASE_URL`: The base url for the app. This is required for Omniauth config.
`OPENID_HOST`: The OID provider hostname, required for authentication. (Do not include URL prefix.)
`OPENID_SECRET_KEY`: The secret key for the OID client.
`OPENID_CLIENT_ID`: The identifier for the OID client.
`OPENID_ISSUER`: The URL for the OIDC issuer. This can be found in the Touchstone OpenID metadata.

#### Required in PR builds

The config below is needed to run Omniauth in developer mode in Heroku review apps. Rather than relying upon a single
ENV value, we use the `FakeAuthConfig` module to perform additional checks that confirm whether developer mode should
be enabled. This assures that developer mode is never enabled in staging or production apps.

`FAKE_AUTH_ENABLED`: Switches Omniauth to developer mode when set. If unset, PR builds will attempt to authenticate with
OIDC, which will fail as their domains are not registered with the provider. (Note: Developer mode is also enabled
whenever the app is started in the development environment.)
`HEROKU_APP_NAME`: Used by the FakeAuthConfig module to determine whether an app is a PR build. If this is set along
with `FAKE_AUTH_ENABLED`, then Omniauth will use Developer mode. Heroku sets this variable automatically for review
apps; it should never be manually set or overridden in any environment.

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
