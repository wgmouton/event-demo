defmodule EventDemo.Deamon.EventService do
  use GenServer

  require Logger

  alias EventDemo.Connector.AWS

  def post_topic(payload) do
    GenServer.call(__MODULE__, {:post, payload})
  end

  def check_health() do
    GenServer.call(__MODULE__, :health_check)
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
          "working"
        end

      send(pid, {ref, response})
    end)

    {:noreply, state}
  end

  def handle_continue(:start, %{status: :dead}) do
    Logger.info("Node is dead, create kafka cluster")

    with :ok <- AWS.create_kafka() do
      {:noreply, %{status: :healthy}, {:continue, :health_check}}
    else
      _ -> {:stop, "Unable to start kafka. Trying to recreate node"}
    end
  end

  def handle_continue(:health_check, %{status: :healthy} = state) do
    Logger.info("Node is was started, check that the kafka clsuter is health")

    {:ok, pid} = KafkaEx.create_worker(:pr, uris: [{"localhost", 9092}])

    IO.inspect(pid)

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
    Logger.info("start event service")

    {:ok, %{status: :dead}, {:continue, :start}}
  end
end
