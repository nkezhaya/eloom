Application.put_env(:eloom, :flush, false)

Benchee.run(
  %{
    "track events" => fn ->
      Eloom.EventBuffer.track("click", %{})
    end
  },
  time: 1,
  memory_time: 2,
  parallel: 100
)
