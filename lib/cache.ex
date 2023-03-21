defmodule ExAssignment.Cache do
  @moduledoc """
  Cache module for the todo app.
  """

  use GenServer

  import Logger

  alias ExAssignment.Todos
  alias ExAssignment.Todos.Todo

  # Client

  @doc """
  Starts the server.
  """
  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(args \\ []), do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  @doc """
  Returns the recommended todo.
  """
  @spec get_recommended() :: %Todo{} | nil
  def get_recommended(), do: GenServer.call(__MODULE__, :get_recommended)

  @doc """
  Marks a todo as done.
  """
  @spec remove(non_neg_integer()) :: :ok
  def remove(id), do: GenServer.cast(__MODULE__, {:remove, id})

  # Server

  def init(_args) do
    {:ok, recommended()}
  end

  def handle_call(:get_recommended, _from, nil) do
    Logger.debug("Cache get_recommended called, but no recommended todo found.")

    state = recommended()
    {:reply, state, state}
  end

  def handle_call(:get_recommended, _from, state) do
    Logger.debug("Cache get_recommended called.")

    {:reply, state, state}
  end

  def handle_cast({:remove, _}, nil), do: {:noreply, nil}

  def handle_cast({:remove, id}, state) do
    Logger.debug("Cache remove called, removing todo #{id}. cache: #{state.id}")

    if id == state.id |> Integer.to_string(),
      do: {:noreply, recommended()},
      else: {:noreply, state}
  end

  # Priv

  defp recommended() do
    Logger.debug("New recommendation called.")

    Todos.list_todos(:open)
    |> Todos.get_recommended()
  end
end
