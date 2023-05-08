defmodule LiveElist.ChatServer do
  alias Ecto.UUID
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def create_room(room_name) do
    room_id = UUID.generate()
    new_room = %{id: room_id, messages: [], name: room_name}
    Agent.update(__MODULE__, &Map.put(&1, room_id, new_room))
    new_room
  end

  def list_rooms do
    Agent.get(__MODULE__, &Map.values(&1))
  end

  def get_room(room_id) do
    Agent.get(__MODULE__, &Map.get(&1, room_id))
  end

  def send_message_to_room(message, room_id) do
    Agent.update(
      __MODULE__,
      &Map.update(&1, room_id, nil, fn state ->
        %{state | messages: List.insert_at(state.messages, -1, message)}
      end)
    )
  end
end
