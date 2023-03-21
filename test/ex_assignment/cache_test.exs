defmodule ExAssignment.CacheTest do
  use ExAssignment.DataCase

  alias ExAssignment.{Cache, Todos}

  import ExAssignment.TodosFixtures

  describe "cache" do
    setup do
      todo = todo_fixture(%{done: false, priority: 1})

      {:ok, todo: todo}
    end

    test "get_recommended/1 returns the recommended todo", %{todo: todo} do
      start_supervised(Cache, start: {Cache, :start_link, []})
      assert Cache.get_recommended() == todo
    end

    test "remove/1", %{todo: todo} do
      start_supervised(Cache, start: {Cache, :start_link, []})

      second = todo_fixture(%{done: false, priority: 99})
      # already cached by init
      assert Cache.get_recommended() == todo

      # not the suggested
      Cache.remove(todo.id + 99)
      assert Cache.get_recommended() == todo

      # suggested
      Todos.check(todo.id)
      Cache.remove(todo.id)
      assert Cache.get_recommended() == second

      # last one
      Todos.check(second.id)
      Cache.remove(second.id)
      assert Cache.get_recommended() == nil
    end
  end
end
