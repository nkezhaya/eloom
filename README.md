# Eloom

**Eloom** is a high-throughput event tracking system built for Elixir apps.

## Features

* **High performance ingestion** using Elixir’s lightweight processes and ETS
* **Pluggable storage backends** (PostgreSQL, ClickHouse support in progress)
* **JSONL import compatibility** with [Mixpanel exports](https://docs.mixpanel.com/docs/data-exports/exporting-raw-data)
* **IP-based geolocation** using MaxMind, with background syncing via configurable account ID and license key
* **Minimal latency** through batching and asynchronous writes
* **Open source & self-hostable**

## Installation

### 1. Install via Mix

```elixir
def deps do
  {:eloom, "~> 0.1"}
end
```

### 2. Configuration

```elixir
# config/config.exs

config :eloom,
  repo: MyApp.Repo,
  event_repo: MyApp.EventRepo,
  geoip: [
    # Obtained from MaxMind's GeoIP.conf
    account_id: "account id",
    license_key: "license key",
    edition: "edition"
  ]
```

### 3. Update your Phoenix router

```elixir
defmodule MyAppWeb.Router do
  import EloomWeb.Router

  eloom "/eloom"
end
```

## TODO

- [ ] Storing all the created reports in Postgres, writing out the schemas/tables for that
- [ ] Funnel reports
- [ ] Breakdown of visitors by country/region/device/whatever
- [ ] UTM things
- [ ] Filtering raw events
- [ ] Event data dump
- [ ] The whole JavaScript tracking library that sends events to Eloom from the end user's browser
- [x] GeoIP integration, updating the database automatically using a license key
- [ ] Optional fallback to Postgres only if the library users don't want to set up ClickHouse
- [ ] Test coverage for... all of that.
- [ ] A cute README file

Later:

- [ ] Retention reports
- [ ] "Insights" reports (top events before and after a given event type)
