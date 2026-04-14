defmodule RewovenQuizWeb.Router do
  use RewovenQuizWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RewovenQuizWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", RewovenQuizWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/", RewovenQuizWeb do
    pipe_through :browser

    live_session :game, layout: {RewovenQuizWeb.Layouts, :bare} do
      live "/host", HostLive
      live "/play", PlayLive
      live "/play/:code", PlayLive
    end
  end
end
