defmodule EloomWeb.HomeLive do
  use EloomWeb, :live_view

  alias Eloom.Reports

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:days, 30)
     |> assign_sessions()}
  end

  defp assign_sessions(%{assigns: %{days: days}} = socket) do
    assign(socket, :sessions, %{
      curr: Reports.count_sessions(days),
      prev: Reports.count_sessions(days..(days + days))
    })
  end

  def render(assigns) do
    ~H"""
    <div>
      <h3 class="text-base font-semibold text-gray-900">Last {@days} days</h3>
      <dl class="mt-5 grid grid-cols-1 divide-y divide-gray-200 overflow-hidden rounded-lg bg-white shadow-sm md:grid-cols-3 md:divide-x md:divide-y-0">
        <div class="px-4 py-5 sm:p-6">
          <dt class="text-base font-normal text-gray-900">Sessions</dt>
          <dd class="mt-1 flex items-baseline justify-between md:block lg:flex">
            <div class="flex items-baseline text-2xl font-semibold text-indigo-600">
              {number_to_delimited(@sessions.curr)}
              <span class="ml-2 text-sm font-medium text-gray-500">
                from {number_to_delimited(@sessions.prev)}
              </span>
            </div>

            <.percent_change curr={@sessions.curr} prev={@sessions.prev} />
          </dd>
        </div>
        <div class="px-4 py-5 sm:p-6">
          <dt class="text-base font-normal text-gray-900">Avg. Open Rate</dt>
          <dd class="mt-1 flex items-baseline justify-between md:block lg:flex">
            <div class="flex items-baseline text-2xl font-semibold text-indigo-600">
              58.16% <span class="ml-2 text-sm font-medium text-gray-500">from 56.14%</span>
            </div>

            <div class="inline-flex items-baseline rounded-full bg-green-100 px-2.5 py-0.5 text-sm font-medium text-green-800 md:mt-2 lg:mt-0">
              <UI.Icon.arrow_up class="mr-0.5 -ml-1 size-5 shrink-0 self-center text-green-500" />
              <span class="sr-only"> Increased by </span> 2.02%
            </div>
          </dd>
        </div>
        <div class="px-4 py-5 sm:p-6">
          <dt class="text-base font-normal text-gray-900">Avg. Click Rate</dt>
          <dd class="mt-1 flex items-baseline justify-between md:block lg:flex">
            <div class="flex items-baseline text-2xl font-semibold text-indigo-600">
              24.57% <span class="ml-2 text-sm font-medium text-gray-500">from 28.62%</span>
            </div>

            <div class="inline-flex items-baseline rounded-full bg-red-100 px-2.5 py-0.5 text-sm font-medium text-red-800 md:mt-2 lg:mt-0">
              <svg
                class="mr-0.5 -ml-1 size-5 shrink-0 self-center text-red-500"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden="true"
                data-slot="icon"
              >
                <path
                  fill-rule="evenodd"
                  d="M10 3a.75.75 0 0 1 .75.75v10.638l3.96-4.158a.75.75 0 1 1 1.08 1.04l-5.25 5.5a.75.75 0 0 1-1.08 0l-5.25-5.5a.75.75 0 1 1 1.08-1.04l3.96 4.158V3.75A.75.75 0 0 1 10 3Z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="sr-only"> Decreased by </span>
              4.05%
            </div>
          </dd>
        </div>
      </dl>
    </div>
    """
  end

  defp percent_change(%{curr: curr, prev: prev} = assigns) do
    percent = round((curr - prev) / prev * 100)
    assigns = assign(assigns, :percent, percent)

    {background_class, text_class, icon_class} =
      if percent > 0 do
        {"bg-green-100", "text-green-800", "text-green-500"}
      else
        {"bg-red-100", "text-red-800", "text-red-500"}
      end

    assigns =
      assign(assigns,
        background_class: background_class,
        text_class: text_class,
        icon_class: "mr-0.5 -ml-1 size-5 shrink-0 self-center #{icon_class}"
      )

    ~H"""
    <div class={"inline-flex items-baseline rounded-full #{@background_class} px-2.5 py-0.5 text-sm font-medium #{@text_class} md:mt-2 lg:mt-0"}>
      <%= if @percent > 0 do %>
        <UI.Icon.arrow_up class={@icon_class} />
      <% else %>
        <UI.Icon.arrow_down class={@icon_class} />
      <% end %>
      <span class="sr-only">
        <%= if @percent > 0 do %>
          Increased
        <% else %>
          Decreased
        <% end %>
        by
      </span>
      {@percent}%
    </div>
    """
  end
end
