defmodule Trello.SessionController do
  use Trello.Web, :controller

  plug :scrub_params, "session" when action in [:create]

  def create(conn, %{"session" => session_params}) do
    case Trello.Session.authenticate(session_params) do
      {:ok, user} ->
        {:ok, jwt, _full_claims} = user |> Guardian.encode_and_sign(:token)

        conn
        |> put_status(:created)
        |> render("show.json", jwt: jwt, user: user)

      :error ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json")
    end
  end

  def unauthenticate(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render(Trello.SesseionView, "forbidden.json", error: "Not authenticated")
  end
end
