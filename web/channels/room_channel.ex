defmodule Chat.RoomChannel do
  use Phoenix.Channel
  require Logger

  def join(room, message, socket) do
    Logger.debug "> join to #{room} #{inspect message}"
    Process.flag(:trap_exit, true)
    # :timer.send_interval(2000, :ping)
    {:ok, %{messages: "joined"}, socket}
  end

  # def handle_in("update", msg, socket) do
  #   Logger.debug "catch new:msg #{inspect msg} from #{inspect socket}"
  #   Logger.debug "catch new:msg #{inspect msg} from"
  #   broadcast! socket, "update", %{user: msg["username"], x: msg["x"], y: msg["y"]}
  #   {:reply, {:ok, msg["body"]}, assign(socket, :user, next)}
  # end

  def handle_in("update", msg, socket) do
    # Logger.debug "update #{inspect msg} from #{inspect socket}"
    Logger.debug "update #{inspect msg}"
    agent = get_agent socket.topic
    Agent.update agent, fn state -> Dict.put state, msg["username"], msg end
    next = Agent.get(agent, fn i -> i end)
    # IO.inspect Agent.get(agent, fn i -> i end)
    # next = %{}

    broadcast! socket, "update", next
    {:reply, {:ok, msg["body"]}, assign(socket, :user, next)}
  end

  def get_agent(room_id) do
    atom = String.to_atom room_id
    pid = Process.whereis atom
    case pid do
      nil ->
        {:ok, pid} = Agent.start_link(fn -> %{} end, name: atom)
        pid
      _ -> pid
    end
  end

  # def handle_info(:ping, socket) do
  #   push socket, "update", %{user: "SYSTEM", body: "ping"}
  #   {:noreply, socket}
  # end

  # def handle_info(obj, socket) do
  #   Logger.debug "> join #{socket.topic}"
  #   broadcast! socket, "user:entered", %{user: msg["user"]}
  #   push socket, "join", %{status: "connected"}
  #   {:noreply, socket}
  # end
  #

  #
  # def terminate(reason, socket) do
  #   Logger.debug"> leave #{inspect reason}"
  #   :ok
  # end
end
