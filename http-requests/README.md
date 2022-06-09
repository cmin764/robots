# Test RPA.HTTP library

## Tasks

### Zamzar Gif To Png

This task converts [portrait.gif](./devdata/portrait.gif) into a downloadable PNG.

- Uses Vault secret `zamzar_jose` which contains an API key identified by
  `api_key_name` variable. (e.g.: `api_key_cosmin: 2392********974e` and
  `api_key_name = "api_key_cosmin"`)
- Runs with one of the following two Work Items:
  - **rpa-http**: Uses `RPA.HTTP` library (default)
  - **py-requests**: Uses the `Zamzar` robot library which invokes `requests` directly
- Switch between *sandbox* and *live* API with `api_base` under
  [variables.py](./variables.py).
