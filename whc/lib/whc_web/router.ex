defmodule WhcWeb.Router do
  use WhcWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", WhcWeb do
    pipe_through :api

    resources "/whcsites", SiteController, only: [:index, :show]
  end

end
