defmodule LiveElistWeb.RoomController do
  use LiveElistWeb, :controller

  def list(conn, _params) do
    render(conn, :list)
  end

  def detail(conn, %{"room_id" => room_id}) do
    render(conn, :detail, room_id: room_id, page_title: "Testing page title")
  end
end
