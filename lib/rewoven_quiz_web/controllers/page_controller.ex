defmodule RewovenQuizWeb.PageController do
  use RewovenQuizWeb, :controller

  def home(conn, _params) do
    conn
    |> put_layout(false)
    |> render(:home)
  end
end
