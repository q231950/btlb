# Plan: PAIA patron login for GBV libraries (Staatsbibliothek zu Berlin, DE-1)

Status: draft, nothing implemented yet.

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

## Open questions (answer with a real login)

1. Exact scope names: spec says both `read_items`/`write_items` and `read_item`/`write_item`. DE-1 test client lists `read_patron read_fees read_items write_items read_availability change_password reset_password update_patron update_patron_email`.
2. Username format: library card number? With or without prefix? Does the OPAC password work?
3. Patron id format returned by login (needed for URL escaping).
4. Real date formats of `starttime`/`endtime`/`expires`/`fee.date` (timezone? date only?).
5. What `item` URIs look like, and whether they contain the barcode BTLB uses as `loanBarcode`.
6. Whether `about` holds title and author together, and in what format.
7. Whether `canrenew`, `renewals`, `queue`, `reminder` are actually filled.
8. Fee amount format and `feetype` values.
9. Token lifetime (`expires_in`).
10. What a refused renewal looks like (`error` text, status, `canrenew`).
11. Whether reserved/ready-for-pickup items (status 1, 4) appear and how BTLB should treat them (probably skip for v1, only status 3 are loans).

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
     - `item` URI → `renewal_token`; barcode → `item_number` (from item URI or label, per Step 1 findings)
     - `about` → title/author, `label` → signature, `canrenew` → `can_renew`, `renewals` → `renewals_count`
     - fees: parse `"2.00 EUR"` → `f64`, `date` → epoch seconds, `about`/`feetype` → reason
     - renew response doc → `Loan`; doc `error` → renewal failure
   - map `access_denied` on login → `ValidationStatus::Invalid`, `invalid_grant` → re-login once.
4. Add `API::Paia` arms to `authenticators/scrape_authenticator.rs` (`verify_credentials`), `scrapers/library_scraper.rs` (`fetch_account`), `scrapers/renewal_service.rs` (`renew`).
5. Fixtures under `src/fixtures/paia/{login,patron,items,fees,renew,errors}/` from the anonymised captures; unit tests for every mapper and error case, following the existing `#[cfg(test)]` + `fs::read_to_string` pattern.
6. `src/model/library_list.rs`: switch `BERLIN` to `api: API::Paia { base_url: "https://paia.gbv.de/DE-1" }`, keep `search_api: K10plusSru`. Same identifier, so existing accounts carry over; old renewal tokens are replaced on the next account update.
7. `cargo test`, then `make apple` to rebuild the Swift package.

## Step 3: BTLB app

1. Bump the paper submodule pointer.
2. `PaperMapper.swift`: map new fields/errors if any were added (keep `PaperErrorInternal` switch exhaustive).
3. `RenewUseCase.swift`: no change expected if the item URI goes through `renewalToken`.
4. Build in Xcode, run unit tests.
5. Manual test with a real SBB account: sign in, loans shown with correct due dates, fees shown, renew one item, wrong password shows the invalid-credentials message, existing BERLIN account keeps working after update.

## Later

- Other GBV libraries with PAIA (check `https://paia.gbv.de/<ISIL>/` for MAGDEBURG, LUENEBURG, BRAUNSCHWEIG, KIEL, ...) and switch them the same way.
- Cache the token for `expires_in` instead of logging in on every update.
- Show reservations / ready-for-pickup items (status 1 and 4), cancel reservations.
