defmodule Whc.SitesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Whc.Sites` context.
  """

  @doc """
  Generate a site.
  """
  def site_fixture(attrs \\ %{}) do
    {:ok, site} =
      attrs
      |> Enum.into(%{
        name_en: "some name_en"
      })
      |> Whc.Sites.create_site()

    site
  end
end
