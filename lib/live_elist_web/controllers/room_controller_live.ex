defmodule LiveElistWeb.RoomControllerLive do
  alias LiveElist.ChatServer
  use LiveElistWeb, :live_view

  @topic "chat_server"
  defp room_topic(room_id) do
    "chat_server:#{room_id}"
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      LiveElistWeb.Endpoint.subscribe(@topic)
    end

    {:ok,
     socket
     |> assign(
       :rooms,
       ChatServer.list_rooms()
     )
     |> assign(:messages, [])}
  end

  def handle_params(%{"id" => room_id}, _uri, socket) do
    if connected?(socket) do
      LiveElistWeb.Endpoint.subscribe(room_topic(room_id))
    end

    {:noreply, socket |> assign(:room_id, room_id) |> assign_room_for_id(room_id)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info(
        %{event: "new_room", topic: @topic, payload: room},
        socket
      ) do
    {:noreply, socket |> assign(rooms: List.insert_at(socket.assigns.rooms, 0, room))}
  end

  def handle_info(%{event: "new_message", topic: topic, payload: message}, socket) do
    if topic == room_topic(socket.assigns.room_id) do
      {:noreply,
       socket
       |> assign(messages: List.insert_at(socket.assigns.messages, -1, message))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("new_room", %{"room_name" => room_name}, socket) do
    room = ChatServer.create_room(room_name)

    LiveElistWeb.Endpoint.broadcast(@topic, "new_room", room)
    {:noreply, socket}
  end

  def handle_event("new_message", %{"message" => message}, socket) do
    ChatServer.send_message_to_room(message, socket.assigns.room_id)

    LiveElistWeb.Endpoint.broadcast(room_topic(socket.assigns.room_id), "new_message", message)

    {:noreply, socket}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <%= if @live_action == :show do %>
      <div
        :for={message <- @messages}
        class="border-dashed border-2 border-sky-500 p-2 my-2 bg-slate-200 w-fit max-w-lg"
      >
        <%= message %>
      </div>

      <div class="fixed bottom-0 mb-4">
        <form phx-submit="new_message">
          <input
            autofocus
            class="input-text"
            type="text"
            name="message"
            placeholder="Type your message..."
          />
        </form>
      </div>
    <% else %>
      Please select a room...
    <% end %>
    """
  end

  defp assign_room_for_id(socket, room_id) do
    assign(socket, :messages, ChatServer.get_room(room_id).messages)
  end
end
