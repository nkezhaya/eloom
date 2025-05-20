- Storing all the created reports in Postgres, writing out the schemas/tables for that
- Funnel reports
- Breakdown of visitors by country/region/device/whatever
- UTM things
- Filtering raw events
- Event data dump
- The whole JavaScript tracking library that sends events to Eloom from the end user's browser
- GeoIP integration, updating the database automatically using a license key
    - still needs global genserver
- Optional fallback to Postgres only if the library users don't want to set up ClickHouse
- Test coverage for... all of that.
- A cute README file

Later:

- Retention reports
- "Insights" reports (top events before and after a given event type)
