defmodule Mix.Tasks.Eloom.Import do
  @shortdoc "Imports events from Mixpanel"

  use Mix.Task

  def run(args) do
    {parsed, _} =
      OptionParser.parse!(args,
        strict: [
          file: :string,
          project_secret: :string,
          repo: :string
        ]
      )

    parsed =
      Keyword.filter(parsed, fn {_, value} ->
        not empty?(value)
      end)

    cond do
      Enum.empty?(parsed) ->
        Mix.raise("Please provide a file or project secret.")

      parsed[:file] && parsed[:project_secret] ->
        Mix.raise("Please provide either a file or a project secret, not both.")

      true ->
        :ok
    end

    Mix.Task.run("app.start")

    if parsed[:file] do
      import_from_file(parsed[:file])
    else
      import_from_project_secret(parsed[:project_secret])
    end
  end

  defp import_from_file(file) do
    file
    |> File.stream!()
    |> Stream.each(fn line ->
      line = Jason.decode!(line)

      properties =
        if Map.has_key?(line["properties"], "time") do
          line["properties"]
          |> Map.put(
            "timestamp",
            DateTime.from_unix!(line["properties"]["time"] * 1_000_000, :microsecond)
          )
          |> Map.delete("time")
        else
          line["properties"]
        end

      Eloom.track(line["event"], properties)
    end)
    |> Stream.run()

    Eloom.EventBuffer.flush()
  end

  defp import_from_project_secret(_project_secret) do
    # TODO
  end

  defp empty?(nil), do: true

  defp empty?(bin) when is_binary(bin) do
    String.trim(bin) == ""
  end
end
