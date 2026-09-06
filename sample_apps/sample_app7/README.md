# Three-column Kanban API

Sample app 7 is cloned from [sample app 5](../sample_app5/README.md) and extends
its cards and nested comments into a single-board API. The fixed columns, in
order, are **Todo**, **In Progress**, and **Done**. These exact strings are the
`status` values used in requests and responses.

Features include card and comment CRUD, a grouped board view with counts,
drag-and-drop ordering within and across columns, priorities, assignees, due
dates, search, filters, pagination, and archive/restore. Data persists in the
sample's own SQLite database, `kanban7.db`. The namespace is `SampleApp7`; the
Rack entrypoint is `SampleApp7::App.app`.

## Setup and verification

From `sample_apps/sample_app7`:

```sh
bundle install
bundle exec rake db:migrate
bundle exec rake routes
bundle exec rspec
```

Run every sample suite with `bundle exec rake` from `sample_apps`.
Use the request and Rack entrypoint specs for development verification; do not
start the server directly during development.

Migrations are explicit; booting the app never creates tables. Migration 002
also upgrades existing cards from the original schema, assigning positions by
ID within each column. Tests migrate private in-memory databases and never open
the development database. `DATABASE_URL`, `DB_POOL_SIZE`, and `DB_POOL_TIMEOUT`
configure connections; the default is SQLite inside this sample directory.

## Endpoints

| Method | Path | Behavior |
| --- | --- | --- |
| GET / HEAD | `/board` | All three columns, ordered cards, filtered counts and pagination |
| GET / HEAD | `/cards` | Ordered, filtered card list (a JSON array) |
| POST | `/cards` | Create a card; returns 201 |
| GET / HEAD | `/cards/:id` | Card with a paginated comments array |
| PATCH / PUT | `/cards/:id` | Update supplied fields, move, archive or restore |
| PATCH | `/cards/:id/move` | Move using `status`, `position`, or both |
| DELETE | `/cards/:id` | Delete the card and its comments; compact its column |
| GET / HEAD | `/cards/:card_id/comments` | Paginated comments |
| POST | `/cards/:card_id/comments` | Create a comment; returns 201 |
| GET / HEAD | `/cards/:card_id/comments/:id` | Show a comment |
| PATCH / PUT | `/cards/:card_id/comments/:id` | Update a comment |
| DELETE | `/cards/:card_id/comments/:id` | Delete a comment |

The original `POST /cards/:id` and `POST /cards/:id/delete` compatibility routes
are retained. Comments also retain equivalent POST aliases and the shallow
`/comments/:id` show/update/delete routes. There is no parentless comments
collection. Comment lookups and mutations under a card are scoped to that URL
parent; body and query fields cannot change the parent.

## Card fields

| Field | Rules |
| --- | --- |
| `title` | Required on create; nonblank string, maximum 100 characters |
| `description` | String or null, maximum 10,000 characters |
| `status` | `Todo` (default), `In Progress`, or `Done` |
| `position` | Zero-based integer within the destination column; omitted creates/moves append |
| `priority` | `low`, `normal` (default), `high`, or `urgent` |
| `assignee` | String or null, maximum 100 characters; a display name, not a user account |
| `due_date` | A valid `YYYY-MM-DD` date or null |
| `archived` | Boolean, default false |

`id`, `created_at`, and `updated_at` are read-only response fields. Unknown input
fields are ignored. JSON bodies must be objects. PATCH and PUT both update only
supplied fields. Send null to clear description, assignee, or due date.

Create a card with `POST /cards`:

```json
{
  "title": "Ship the Kanban API",
  "description": "Verify the board workflow",
  "priority": "high",
  "assignee": "Alice",
  "due_date": "2026-09-30"
}
```

Create and update responses contain `{ "message": "...", "card": { ... } }`.
Show returns `{ "card": { ... }, "comments": [ ... ] }`.
Delete returns the removed card with a message. Comments use analogous response
envelopes; comment show returns the comment object directly.

## Moving, ordering and archiving

Move a card to the top of In Progress with `PATCH /cards/1/move`:

```json
{"status": "In Progress", "position": 0}
```

Positions refer to the complete active destination column, regardless of current
filters or pagination. The moved card is excluded when calculating the target
index. Valid positions are from zero through the number of other active cards in
that column, inclusive. Out-of-range positions return 422. Moving within a column
without a position keeps its position; changing columns without one appends.
Cards can move freely between all three columns, including reopening Done cards.
The move endpoint accepts only status and position and requires at least one.

Standard PATCH/PUT card updates also accept status and position, so editing a card
and moving it can happen atomically. SQLite immediate transactions serialize
writers before reading positions. Insertion, movement, archive/restore and
deletion shift affected neighbors and preserve contiguous zero-based positions;
failed validation rolls back the entire change. Neighbor timestamps also update.

Archive with `PATCH /cards/1` and `{"archived": true}`. Archived cards keep their
status, metadata and comments but have a null position and disappear from the
board and default card list. Browse them with `/cards?archived=true`; individual
card and comment routes remain available. Archived cards cannot be moved until
restored (409), and cannot be assigned a position (400).

Restore with `{"archived": false}` to append to the original column, or include
status and/or position to choose the destination. Deleting a card is permanent
and cascades to its comments.

## Board, filters and pagination

`GET /board` always returns the three columns, including empty ones:

```json
{
  "columns": [
    {"status": "Todo", "total": 0, "cards": []},
    {"status": "In Progress", "total": 0, "cards": []},
    {"status": "Done", "total": 0, "cards": []}
  ],
  "total": 0,
  "limit": 25,
  "offset": 0
}
```

Both `/board` and `/cards` accept these query parameters:

| Parameter | Behavior |
| --- | --- |
| `status` | Exact column status |
| `priority` | Exact priority |
| `assignee` | Exact assignee name |
| `q` | Case-insensitive literal substring search in title and description; maximum 200 characters |
| `overdue` | Boolean; overdue means due before the server's current date and status other than Done |
| `limit` | Default 25, minimum 1, maximum 100 |
| `offset` | Default 0, minimum 0, maximum 10,000 |

`/cards` additionally accepts `archived=true` to list only archived cards; false
is the default. `/board` always shows active cards and rejects `archived=true`.
Boolean inputs accept JSON booleans and the form/query strings `true`, `false`,
`1`, and `0`. Filters combine with AND. `overdue=false` includes undated cards,
Done cards, and cards due today or later.

For example, `/cards?status=In%20Progress&priority=high&assignee=Alice&q=API` lists
Alice's high-priority In Progress cards matching API.

On `/board`, limit and offset apply **independently to each column**, and totals
count all matching cards before pagination. On `/cards`, pagination applies to
the entire list, sorted by column order, then position, then ID. Comments are
ordered by ID and use the same pagination bounds, including embedded comments on
card show. A comment requires nonblank `content` (maximum 1,000 characters) and
accepts an optional `author` (maximum 100 characters).

## Errors and architecture

Errors are JSON objects with `error` and `request_id`; validation errors include
field-keyed `details`. Malformed input and invalid query parameters return 400,
missing resources return 404, moving an archived card returns 409, and invalid
field values or out-of-range positions return 422. Unsupported methods return
405. The framework limits request bodies to 1 MiB.

Controllers own queries, input validation and multi-record transactions. Explicit
card writes return raw attributes to prevent automatic dispatch from saving or
destroying twice. Comment actions retain the framework's automatic persistence.
Handlers only filter and format prepared data; they never access the database.

This sample is a public, single-board API without authentication or user accounts.
See the [routing guide](../../docs/routing.md) for authenticated parent scoping.
