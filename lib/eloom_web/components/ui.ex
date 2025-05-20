defmodule EloomWeb.UI do
  use Phoenix.Component

  def date_range_button_group(assigns) do
    ~H"""
    <span class="isolate inline-flex rounded-md shadow-xs">
      <.date_range_button>Custom</.date_range_button>
      <.date_range_button>Today</.date_range_button>
      <.date_range_button>Yesterday</.date_range_button>
      <.date_range_button>7D</.date_range_button>
      <.date_range_button>30D</.date_range_button>
      <.date_range_button>3M</.date_range_button>
      <.date_range_button>6M</.date_range_button>
      <.date_range_button>12M</.date_range_button>
    </span>
    """
  end

  defp date_range_button(assigns) do
    ~H"""
    <button
      type="button"
      class="relative -ml-px inline-flex items-center first:rounded-l-md last:rounded-r-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 ring-1 ring-gray-300 ring-inset hover:bg-gray-50 focus:z-10 cursor-pointer"
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
