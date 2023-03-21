defmodule ExAssignment.Helper do
  @moduledoc """
  Some helper functions for the todo app.
  """
  alias ExAssignment.Todos.Todo

  @doc """
  Returns the total points of all todos.
  """
  @spec total_points(%Todo{}) :: non_neg_integer()
  def total_points([]), do: 0
  def total_points(todos), do: todos |> Enum.reduce(0, &(&2 + &1.priority))

  @doc """
  Returns a list of todos with their accumulated probability.
  """
  @spec get_probabilities(non_neg_integer(), list(%Todo{})) :: list({%Todo{}, float()})
  def get_probabilities(total_points, todos) do
    list =
      todos
      |> Enum.map(fn todo ->
        # Probability of being rejected
        selection_probability = todo.priority / total_points
        reciprocal = (1 / selection_probability) |> Float.round(4)
        {todo, reciprocal}
      end)

    total =
      list
      |> Enum.reduce(0, fn {_, p}, acc -> acc + p end)

    list
    |> Enum.map(fn {todo, probability} -> {todo, probability / total} end)
    # higher priority first
    |> Enum.sort_by(fn {_, probability} -> probability end)
    |> accumulative_probabilities()
  end

  defp accumulative_probabilities(list) do
    list
    |> Enum.reduce({0, []}, fn {todo, probability}, {acc, acc_list} ->
      {acc + probability, [{todo, acc + probability} | acc_list]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end
end
