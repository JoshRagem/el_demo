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
    # TODO: i18n here?
    %{
      id: site.id,
      name: site.name_en,
      short_description: site.short_description_en,
      justification: site.justification_en,
      date_inscribed: site.date_inscribed,
      danger: site.danger,
      danger_list: site.danger_list,
      longitude: site.longitude,
      latitude: site.latitude,
      states_name: site.states_name_en,
      region: site.region_en
    }
  end
end
