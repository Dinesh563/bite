defmodule BiteWeb.PageController do
  use BiteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
