defmodule EventDemo.Deamon.EventService do
  use GenServer

  alias EventDemo.Connector.AWS

  def post_topic(payload) do
    GenServer.call({:post, payload}, __MODULE__)
  end

  def check_health() do
    GenServer.call(:health_check, __MODULE__)
  end

  def handle_call(_message, _from, %{status: :starting}) do
    {:error, "The cluster is starting up."}
  end

  def handle_call(_message, _from, %{status: :dead}) do
    {:error, "The cluster has not yet started."}
  end

  def handle_call({:post, payload}, {pid, ref}, %{status: :healthy} = state) do
    spawn_link(fn ->
      response =
        with :ok <- AWS.post_topic() do
          %{}
        end

      send(pid, {ref, response})
    end)

    {:noreply, state}
  end

  def handle_call(:health_check, {pid, ref}, %{status: :healthy} = state) do
    spawn_link(fn ->
      response =
        with :ok <- AWS.check_health() do
          %{}
        end

      send(pid, {ref, response})
    end)

    {:noreply, state}
  end

  def handle_continue(_continue, %{status: :dead}) do
    with :ok <- AWS.create_kafka(),
         :ok <- AWS.check_health() do
      {:noreply, %{status: :healthy}}
    else
      _ -> {:stop, "Unable to start kafka. Trying to recreate node"}
    end
  end

  def handle_continue(_continue, %{status: :healthy} = state) do
    with :ok <- AWS.check_health() do
      {:noreply, state}
    else
      _ -> {:stop, "error"}
    end
  end

  def start_link(_int) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_int) do
    {:ok, %{status: :dead}, {:continue, :continue}}
  end
end
