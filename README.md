# tacos

## Required Environment Variables

`LINKRESOLVER_BASEURL`: base url for our link resolver. `https://mit.primo.exlibrisgroup.com/discovery/openurl?institution=01MIT_INST&rfr_id=info:sid/mit.tacos.api&vid=01MIT_INST:MIT` is probably the best value unless you are doing something interesting.

`UNPAYWALL_EMAIL`: email address to include in API call as required in their [documentation](https://unpaywall.org/products/api). Your personal email is appropriate for development. Deployed and for tests, use the timdex moira list email.
