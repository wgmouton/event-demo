defmodule EventDemo.Deamon.EventService do
  use GenServer

  alias EventDemo.Connector.AWS

  defp test do
    :ok
  end

  def post_topic(payload) do
    GenServer.call({:post, payload}, __MODULE__)
  end

  def handle_call(_message, _from, %{status: :starting}) do
    {:error, "The cluster is starting up."}
  end

  def handle_call(_message, _from, %{status: :dead}) do
    {:error, "The cluster has not yet started."}
  end

  def handle_call({:post, payload}, {pid, ref}, %{status: :healthy}) do
    spawn_link(fn ->


      with :ok <- AWS.post_topic
      result = %{}


      send(pid, {ref, result})
    end)

    {:noreply, state}
  end

  def handle_continue(_continue, %{status: :dead}) do
  end

  def handle_continue(_continue, %{status: :healthy} = state) do
    with :ok <- AWS.check_health() do
      {:noreply, state}
    else
      _ -> {:stop, "error"}
    end
  end

  def start_link(_int) do
  end

  def init(_int) do
    {:ok, %{status: :dead}, {:continue, :continue}}
  end
end
