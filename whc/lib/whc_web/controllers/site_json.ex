defmodule WhcWeb.SiteJSON do
  alias Whc.Sites.Site

  @doc """
  Renders a list of whcsites.
  """
  def index(%{whcsites: whcsites}) do
    %{data: for(site <- whcsites, do: data(site))}
  end

  @doc """
  Renders a single site.
  """
  def show(%{site: site}) do
    %{data: data(site)}
  end

  defp data(%Site{} = site) do
    %{
      id: site.id,
      name_en: site.name_en
    }
  end
end
