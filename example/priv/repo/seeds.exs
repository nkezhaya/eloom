defmodule EloomFakeDataGenerator do
  @total_users 100_000

  def generate do
    IO.puts("Starting fake event generation...")

    1..@total_users
    |> Task.async_stream(&generate_user_sessions/1,
      max_concurrency: System.schedulers_online() * 2,
      timeout: :infinity
    )
    |> Stream.run()

    Eloom.EventBuffer.flush()

    IO.puts("Done.")
  end

  defp generate_user_sessions(_) do
    user_id = "user_#{:rand.uniform(1_000_000)}"
    num_sessions = Enum.random(1..5)

    Enum.each(1..num_sessions, fn _ ->
      session_start = random_time_in_last_2_years()
      session_duration = random_session_duration()
      num_events = Enum.random(3..20)

      shared_props = %{
        "plan" => random_plan(),
        "$browser" => random_browser(),
        "$os" => random_os(),
        "$geo" => random_geo(),
        "referrer" => random_referrer(),
        "$distinct_id" => user_id
      }

      Enum.each(0..(num_events - 1), fn i ->
        event_time =
          DateTime.add(session_start, div(i * session_duration, num_events), :second)

        event_name = random_event_name()

        Eloom.track(
          event_name,
          Map.merge(shared_props, %{
            "$insert_id" => random_hex(16),
            "$timestamp" => event_time,
            "page" => random_page()
          })
        )
      end)
    end)
  end

  defp random_hex(bytes) do
    :crypto.strong_rand_bytes(bytes) |> Base.encode16(case: :lower)
  end

  defp random_time_in_last_2_years do
    now = DateTime.utc_now()
    offset = -:rand.uniform(60 * 60 * 24 * 365 * 2)
    DateTime.add(now, offset, :second)
  end

  defp random_plan, do: Enum.random(~w(free pro enterprise))
  defp random_browser, do: Enum.random(~w(Chrome Firefox Safari Edge))
  defp random_os, do: Enum.random(~w(macOS Windows Linux iOS Android))
  defp random_page, do: "/" <> Enum.random(~w(home about dashboard settings profile help))

  defp random_referrer,
    do:
      Enum.random([
        "https://google.com",
        "https://news.ycombinator.com",
        "https://facebook.com",
        "https://linkedin.com",
        nil
      ])

  defp random_session_duration, do: Enum.random(60..600)

  @cities_by_country %{
    "US" => ["New York", "San Francisco", "Chicago"],
    "DE" => ["Berlin", "Hamburg", "Munich"],
    "IN" => ["Mumbai", "Delhi", "Bangalore"],
    "GB" => ["London", "Manchester", "Bristol"],
    "CA" => ["Toronto", "Vancouver", "Montreal"],
    "FR" => ["Paris", "Lyon", "Marseille"],
    "AU" => ["Sydney", "Melbourne", "Brisbane"]
  }

  defp random_geo do
    country = Enum.random(Map.keys(@cities_by_country))
    city = Enum.random(@cities_by_country[country])
    %{"country" => country, "city" => city}
  end

  defp random_event_name do
    Enum.random([
      "page_view",
      "button_click",
      "signup_start",
      "signup_complete",
      "checkout_started",
      "purchase_completed",
      "video_played",
      "modal_closed"
    ])
  end
end

EloomFakeDataGenerator.generate()
