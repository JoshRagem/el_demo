defmodule WhcWeb.SiteController do
  use WhcWeb, :controller

  alias Whc.Sites

  action_fallback WhcWeb.FallbackController

  def index(conn, _params) do
    whcsites = Sites.list_whcsites()
    render(conn, :index, whcsites: whcsites)
  end

  def show(conn, %{"id" => id}) do
    site = Sites.get_site!(id)
    render(conn, :show, site: site)
  end

end
