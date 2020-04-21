defmodule EventService do
  use GenServer

  def post_topic(payload) do
    GenServer.call({:post, payload}, __MODULE__)
  end


  def handle_call(_message, _from, %{ready: :starting}) do
    {:error, "The cluster is starting up."}
  end

  def handle_call(_message, _from, %{ready: :dead}) do
    {:error, "The cluster has not yet started."}
  end

  def handle_call({:post, payload}, _from, _state) do

  end

  def handle_continue() do

  end

  def start_link(_int) do

  end

  def init(_int) do

  end

end
