defmodule EventDemo.HttpServer do
  use Plug.Router

  alias EventDemo.Deamon.EventService

  plug(:match)
  plug(:dispatch)

  get "/" do
    response = EventService.check_health()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  post "/api/v1/events" do
    %Plug.Conn{body_params: request_body} = conn
    response = EventService.post_topic(request_body)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
