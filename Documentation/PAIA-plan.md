# Plan: PAIA patron login for GBV libraries (Staatsbibliothek zu Berlin, DE-1)

Status: Step 2 implemented in paper (`API::Paia`, `src/scrapers/paia/`, BERLIN switched to `https://paia.gbv.de/DE-1`) and unit-tested with `cargo test`. Not yet done: `make apple`, the Xcode build and the manual test of Step 3 (they need macOS), and a real login, renewal and Berlin (DE-1) account. Real responses captured on DE-18 only (see Findings from DE-18).

## Why

Today BERLIN (and other GBV libraries) sign in by scraping the LBS OPAC (`API::Opc4v2_13Vzg6`, `https://lbssbb.gbv.de`). GBV offers PAIA, a JSON patron API, which is sturdier than HTML scraping and also exposes fees, which the current scraper never loads (`// get balance` TODO in `Opc4v2_13Vzg6AccountScraper`).

## PAIA endpoints (DE-1)

Sources: PAIA spec 1.4.0 (https://gbv.github.io/paia/paia.html) and the DE-1 test client (https://paia.gbv.de/DE-1/). The test client shows no real responses, so everything marked "verify" must be checked with a real login (see below).

Base URLs:
- Auth: `https://paia.gbv.de/DE-1/auth`
- Core: `https://paia.gbv.de/DE-1/core/{patron}` (patron id URI-escaped)

HTTPS only. Core calls need `Authorization: Bearer <access_token>`.

### Auth

POST `auth/login`, `application/x-www-form-urlencoded`
- `grant_type=password`, `username`, `password`, optional `scope` (space separated)
- 200: `{ access_token, token_type: "Bearer", expires_in?, patron, scope }`
- Wrong credentials: 403 `{ "error": "access_denied", "error_description": "..." }`

POST `auth/logout` (Bearer) → `{ patron }`

`auth/change` and `auth/reset` exist (password change/reset) but are out of scope.

### Core

GET `core/{patron}` (scope `read_patron`)
- `name`, `email?`, `address?`, `expires?` (datetime), `status?` (0 active, 1 inactive, 2 expired, 3 outstanding fees, 4 expired + fees), `type?` (URIs), `note?`

GET `core/{patron}/items` (scope `read_items`)
- `{ "doc": [ ... ] }`, each document:
  - `status` (1..1): 0 none, 1 reserved, 2 ordered, 3 held (on loan), 4 provided (ready for pickup), 5 rejected
  - `item?`, `edition?` (URIs), `requested?`, `about?` (title/author text), `label?` (shelfmark), `comment?`
  - `queue?`, `renewals?`, `reminder?` (ints)
  - `starttime?`, `endtime?` (datetime; for status 3 = loan start / due date)
  - `canrenew?`, `cancancel?` (bool), `error?`, `storage?`, `storageid?`

POST `core/{patron}/renew` (scope `write_items`), JSON
- Body: `{ "doc": [ { "item": "<item URI>" } ] }`
- Response: `{ "doc": [ ... ] }`, same document shape. A failed renewal is reported in the document's `error`, not as an HTTP error.

POST `core/{patron}/request` and `core/{patron}/cancel`: same body/response shape (not needed for v1).

GET `core/{patron}/fees` (scope `read_fees`)
- `amount?` (total, e.g. `"2.00 EUR"`), `fee: [ { amount, date?, about?, item?, edition?, feetype?, feeid? } ]`

### Errors

JSON `{ error, code?, error_description?, error_uri? }`:
- 401 `invalid_grant`: token missing/expired → log in again
- 403 `insufficient_scope` / `access_denied`
- 404 `not_found`, 422/400 `invalid_request`, 5xx `internal_error`, `service_unavailable`, ...

## Findings from DE-18

A real session against Staatsbibliothek Hamburg (ISIL DE-18, `https://paia.gbv.de/DE-18`). It runs the same software as DE-1 (`vzg-paia/2.9.0`, `X-PAIA-Version: 1.4.0`), so these are a strong hint for Berlin, but each point is observed on DE-18 only: confirm on DE-1.

Only read-only GETs with a Bearer token were run (`core/{patron}`, `/items`, `/fees`). Login itself was not run (the token was supplied), and renew and logout were not tried. Personal data below is replaced by placeholders.

Scopes
- `X-OAuth-Scopes: update_patron_email read_availability write_items read_items read_fees read_patron`: plural `read_items`/`write_items`.
- Responses also send `X-Accepted-OAuth-Scopes` (`read_patron`, `read_items`, `read_fees` for the respective endpoint).

Patron id
- 11-digit card number, e.g. `0018XXXXXXX`. Only digits, so no escaping needed.

GET `core/{patron}`

```json
{ "address": "<address>", "email": "<email>", "expires": "2027-11-30", "name": "<name>", "status": 0, "type": ["de-18:user-type:20"] }
```

- `expires` is date-only.

GET `core/{patron}/items`

```json
{ "doc": [ {
  "about": "Metaanalyse / Eisend, Martin *1968-* (2020)",
  "cancancel": false,
  "canrenew": true,
  "edition": "http://uri.gbv.de/document/opac-de-18:ppn:1686775911",
  "endtime": "2027-01-04",
  "item": "http://uri.gbv.de/document/opac-de-18:bar:XXXXXXXXX",
  "label": "SUB-SB:A 2020/4402",
  "queue": 0,
  "reminder": 0,
  "renewals": 0,
  "starttime": "2026-11-28",
  "status": 3,
  "storage": "<b>Ausleihzentrum</b> Staats- und Universitätsbibliothek",
  "storageid": "http://uri.gbv.de/organization/isil/DE-18@counter-1"
} ] }
```

- `starttime`/`endtime` are date-only, no time or timezone.
- `about` is `Title / Author *lifedates* (year)` in one string: split on ` / ` and handle the trailing `(year)`.
- `item` URI ends in `:bar:<barcode>`, so the barcode (`loanBarcode`) is the part after `:bar:`.
- `edition` URI carries the PPN after `:ppn:`.
- `canrenew`, `renewals`, `queue`, `reminder` are all filled.
- `storage` contains HTML tags (`<b>`) that must be stripped.
- Only status 3 seen (2 loans); the account had no reservations.

GET `core/{patron}/fees`

```json
{ "amount": "1.00 EUR", "fee": [ {
  "about": "<same format as items about>",
  "amount": "1.00 EUR",
  "date": "2025-05-01T00:44:10+02:00",
  "feetype": "Mahngebuehr",
  "feetypeid": "de-18:fee-type:3",
  "item": "http://uri.gbv.de/document/opac-de-18:bar:XXXXXXXXX"
} ] }
```

- `amount` is a string `"<decimal> EUR"`.
- `fee.date` is full ISO 8601 with offset, unlike the date-only loan dates.
- `feetype` is German text without umlauts; there is also a `feetypeid` URI.

Errors
- Invalid token: HTTP 401 `{"code":401,"error":"invalid_grant","error_description":"The access token was missing, invalid or expired"}` (note the extra `code` field).
- Wrong credentials at `auth/login` (dummy user, tested on both DE-1 and DE-18): HTTP 403 `{"error":"access_denied","error_description":"invalid patron or password"}`.

Second session (2026-11-28, same read-only GETs with a supplied token)
- DE-18 answered exactly as above: same fields, date-only `starttime`/`endtime`/`expires`, `"1.00 EUR"`, ISO 8601 fee date, `invalid_grant` body with `code`.
- `about` years also come in brackets, e.g. `Title / Author *1974-* ([2020])`, and titles contain ` : ` before a subtitle. The mapper drops any trailing parenthesis that contains a 4-digit year.
- The DE-18 token is rejected on DE-1: `core/{patron}`, `/items` and `/fees` all answer HTTP 401 with the same `invalid_grant` body. Tokens are bound to the ISIL they were issued by, so DE-1 needs its own login.
- DE-1's 401 comes from the same server (`vzg-paia/2.9.0`, `X-PAIA-Version: 1.4.0`) with `WWW-Authenticate: Bearer realm="PAIA"`, the same headers as on DE-18.

## Open questions (answer with a real login)

1. ~~Exact scope names~~: answered, plural `read_items`/`write_items` (see Findings from DE-18; confirm on DE-1).
2. Username format: library card number? With or without prefix? Does the OPAC password work? Still open (login was not run).
3. ~~Patron id format~~: answered, 11-digit card number, no escaping needed (DE-18; confirm on DE-1).
4. ~~Date formats~~: answered, `starttime`/`endtime`/`expires` date-only, `fee.date` ISO 8601 with offset (DE-18; confirm on DE-1).
5. ~~`item` URIs and barcode~~: answered, `...:bar:<barcode>`, barcode after `:bar:` (DE-18; confirm on DE-1).
6. ~~`about` format~~: answered, `Title / Author *lifedates* (year)` (DE-18; confirm on DE-1).
7. ~~`canrenew`, `renewals`, `queue`, `reminder` filled~~: answered, all filled (DE-18; confirm on DE-1).
8. ~~Fee amount format and `feetype`~~: answered, `"1.00 EUR"`, German `feetype` plus `feetypeid` (DE-18; confirm on DE-1).
9. Token lifetime (`expires_in`). Still open. paper logs in on every update and renewal, so it doesn't depend on it.
10. What a refused renewal looks like (`error` text, status, `canrenew`). Still open (renew was not run). paper assumes the spec: a document with `error` is a refused renewal and its text becomes `PaperError::ErrorWithMessage`. The `renew/refused.json` fixture is made up from the spec.
11. Whether reserved/ready-for-pickup items (status 1, 4) appear and how BTLB should treat them. Still open, the DE-18 account had none. paper skips everything but status 3.
12. Whether DE-1 behaves the same as DE-18. Partly answered: DE-1 runs the same server and PAIA version and sends the same `invalid_grant` and `access_denied` errors, but a DE-18 token is not valid on DE-1 (401 `invalid_grant`), so DE-1's data formats are still unverified and need a Berlin account.

## Step 1: Gather real responses

Run in a terminal by the account owner. Do not paste the password into files or chats; the commands read it from a prompt. Needs `curl` and `jq`.

```sh
mkdir -p ~/paia-capture && cd ~/paia-capture
BASE=https://paia.gbv.de/DE-1
read -r "USER?Library card number: "          # zsh; bash: read -r -p "..." USER
read -rs "PASS?Password: "; echo             # bash: read -rs -p "..." PASS

# 1. Login (try full scope list first)
curl -sS -i "$BASE/auth/login" \
  --data-urlencode grant_type=password \
  --data-urlencode "username=$USER" \
  --data-urlencode "password=$PASS" \
  --data-urlencode "scope=read_patron read_items write_items read_fees" \
  | tee login.txt
unset PASS

TOKEN=$(sed -n '/^{/,$p' login.txt | jq -r .access_token)
PATRON=$(sed -n '/^{/,$p' login.txt | jq -r .patron)
ENC=$(jq -rn --arg p "$PATRON" '$p|@uri')

# 2. Patron, items, fees
curl -sS -H "Authorization: Bearer $TOKEN" "$BASE/core/$ENC"       | jq . > patron.json
curl -sS -H "Authorization: Bearer $TOKEN" "$BASE/core/$ENC/items" | jq . > items.json
curl -sS -H "Authorization: Bearer $TOKEN" "$BASE/core/$ENC/fees"  | jq . > fees.json

# 3. Error cases
curl -sS -i -H "Authorization: Bearer invalid" "$BASE/core/$ENC/items" > error_invalid_token.txt
curl -sS -i "$BASE/auth/login" --data-urlencode grant_type=password \
  --data-urlencode "username=$USER" --data-urlencode "password=wrong" > error_login.txt

# 4. Renew ONE item, only if you actually want it renewed (it really renews!)
#    Pick an item URI from items.json with "canrenew": true
# ITEM='<item URI>'
# curl -sS -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
#   -d "$(jq -n --arg i "$ITEM" '{doc:[{item:$i}]}')" "$BASE/core/$ENC/renew" | jq . > renew.json

# 5. Log out
curl -sS -X POST -H "Authorization: Bearer $TOKEN" "$BASE/auth/logout"
```

If login fails with `insufficient_scope` or `invalid_request`, retry with singular scopes (`read_item write_item`) or without `scope`, and note which one works.

Then anonymise the captures before they become fixtures: replace name, email, address, card number, patron id and the token with dummy values, keeping the formats intact. Answer the open questions above from the captures.

## Step 2: Implement in paper (Rust submodule, `Packages/shared/paper`)

1. `git submodule update --init Packages/shared/paper`, branch in paper.
2. `src/model/api.rs`: add `API::Paia { base_url: String }` plus arms in `base_url()`, `login_url()`, etc., with URL tests.
3. New module `src/scrapers/paia/`:
   - `dto.rs`: serde structs for login, patron, items (`doc`), fees, error.
   - `client.rs`: `login(user, pass) -> (token, patron)`, `patron`, `items`, `fees`, `renew(item_uri)`; Bearer header, form login, JSON renew. Either enable reqwest's `json` feature or parse `.text()` with `serde_json`.
   - `mapper.rs`: pure functions DTO → `Account`, `Loan`, `Balance`, `Charge`:
     - only `status == 3` docs become loans (v1)
     - `endtime` → `date_due` as `dd.MM.yyyy`
     - `item` URI → `renewal_token`; barcode → `item_number` (part of the item URI after `:bar:`, per Findings from DE-18)
     - `about` → title/author, `label` → signature, `canrenew` → `can_renew`, `renewals` → `renewals_count`
     - fees: parse `"2.00 EUR"` → `f64`, `date` → epoch seconds, `about`/`feetype` → reason
     - renew response doc → `Loan`; doc `error` → renewal failure
   - map `access_denied` on login → `ValidationStatus::Invalid`, `invalid_grant` → re-login once.
4. Add `API::Paia` arms to `authenticators/scrape_authenticator.rs` (`verify_credentials`), `scrapers/library_scraper.rs` (`fetch_account`), `scrapers/renewal_service.rs` (`renew`).
5. Fixtures under `src/fixtures/paia/{login,patron,items,fees,renew,errors}/` from the anonymised captures; unit tests for every mapper and error case, following the existing `#[cfg(test)]` + `fs::read_to_string` pattern.
6. `src/model/library_list.rs`: switch `BERLIN` to `api: API::Paia { base_url: "https://paia.gbv.de/DE-1" }`, keep `search_api: K10plusSru`. Same identifier, so existing accounts carry over; old renewal tokens are replaced on the next account update.
7. `cargo test`, then `make apple` to rebuild the Swift package.

Done (branch `add-paia-plan` in paper), steps 1 to 6 and `cargo test`; `make apple` still to do on a Mac:
- `src/scrapers/paia/`: `dto.rs` (serde), `client.rs` (`PaiaClient` per endpoint, `PaiaSession` that signs in again once on `invalid_grant`), `mapper.rs` (pure functions), `mod.rs` (`verify_credentials`, `fetch_account`, `renew`), `test_server.rs` (a local HTTP server for the session tests).
- reqwest's `json` feature is not needed: bodies are read with `.text()` and parsed with `serde_json`.
- Login sends `scope=read_patron read_items write_items read_fees`.
- Loans: `about` → title and author (trailing year and life dates dropped), `label` → `details.signature`, `storage` without HTML → data entry `Standort`, `starttime` → `borrowed_at`, `queue > 0` → `locked_by_preorder`. If an item URI has no `:bar:`, `item_number` is the whole URI.
- Fees: `feetype` → `reason` (falls back to `about`), `about` → `item`, `amount` of the response → `Balance.total` as sent (`"1.00 EUR"`). If `/fees` fails, the account is loaded without a balance.
- `access_denied` (and `invalid_grant`) at login → `IncorrectCredentials` → `ValidationStatus::Invalid`; other PAIA errors → `ErrorWithMessage(error_description)`.
- Search and search details of `API::Paia` are `NotImplementedError`; PAIA libraries search via `search_api`.
- Fixtures in `src/fixtures/paia/`: `patron`, `items`, `fees` and `errors/invalid_grant` are anonymised DE-18 captures; `errors/access_denied` is the observed wrong-credentials body; `login`, `renew` and the other `errors` and `items` files are made up from the spec.

## Step 3: BTLB app

1. Bump the paper submodule pointer.
2. `PaperMapper.swift`: map new fields/errors if any were added (keep `PaperErrorInternal` switch exhaustive).
3. `RenewUseCase.swift`: no change expected if the item URI goes through `renewalToken`.
4. Build in Xcode, run unit tests.
5. Manual test with a real SBB account: sign in, loans shown with correct due dates, fees shown, renew one item, wrong password shows the invalid-credentials message, existing BERLIN account keeps working after update.

Done: 1. Nothing to do for 2 and 3: paper gained no new `PaperError` cases or model fields, the Swift code doesn't switch over `Paper.Api`, and the item URI goes through `renewalToken`. Still to do: `make apple`, 4 and 5 (need macOS and a Berlin account). Until a BERLIN account is updated once, its loans keep their old OPAC renewal tokens, which PAIA will refuse.

## Later

- Other GBV libraries with PAIA (check `https://paia.gbv.de/<ISIL>/` for MAGDEBURG, LUENEBURG, BRAUNSCHWEIG, KIEL, ...) and switch them the same way.
- Cache the token for `expires_in` instead of logging in on every update.
- Show reservations / ready-for-pickup items (status 1 and 4), cancel reservations.
