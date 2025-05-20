defmodule EloomWeb.UI.Icon do
  use Phoenix.Component

  def home(assigns) do
    assigns = assign_defaults(assigns)

    ~H"""
    <.svg stroke-width="1.5" stroke="currentColor" {assigns}>
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"
      />
    </.svg>
    """
  end

  def chart_bar(assigns) do
    assigns = assign_defaults(assigns)

    ~H"""
    <.svg stroke-width="1.5" stroke="currentColor" {assigns}>
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125c0-.621.504-1.125 1.125-1.125h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z"
      />
    </.svg>
    """
  end

  def cursor_arrow_ripple(assigns) do
    assigns = assign_defaults(assigns)

    ~H"""
    <.svg stroke-width="1.5" stroke="currentColor" {assigns}>
      <path
        stroke-linecap="round"
        stroke-linejoin="round"
        d="M15.042 21.672 13.684 16.6m0 0-2.51 2.225.569-9.47 5.227 7.917-3.286-.672Zm-7.518-.267A8.25 8.25 0 1 1 20.25 10.5M8.288 14.212A5.25 5.25 0 1 1 17.25 10.5"
      />
    </.svg>
    """
  end

  def svg(assigns) do
    assigns = assign_defaults(assigns)
    class = assigns[:class] || ""
    classes = [class]

    assigns = assign(assigns, :class, Enum.join(classes, " "))

    assigns =
      case assigns[:fill] do
        false -> assign(assigns, :fill, "none")
        _ -> assigns
      end

    ~H"""
    <svg
      class={@class}
      viewBox={@viewbox}
      fill={@fill}
      xmlns="http://www.w3.org/2000/svg"
      aria-hidden="true"
      stroke={assigns[:stroke]}
      stroke-width={assigns[:"stroke-width"]}
    >
      {render_slot(@inner_block)}
    </svg>
    """
  end

  defp assign_defaults(assigns) do
    assigns
    |> assign_new(:fill, fn -> false end)
    |> assign_new(:viewbox, fn -> "0 0 24 24" end)
    |> assign_new(:color, fn -> "text-black" end)
    |> then(fn a -> assign(a, :class, "#{a[:class]} #{a[:hover]}") end)
  end
end
