defmodule ExAssignment.TodosTest do
  use ExAssignment.DataCase

  alias ExAssignment.Todos

  describe "todos" do
    alias ExAssignment.Todos.Todo

    import ExAssignment.TodosFixtures

    @invalid_attrs %{done: nil, priority: nil, title: nil}

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Todos.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Todos.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      valid_attrs = %{done: true, priority: 42, title: "some title"}

      assert {:ok, %Todo{} = todo} = Todos.create_todo(valid_attrs)
      assert todo.done == true
      assert todo.priority == 42
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{done: false, priority: 43, title: "some updated title"}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, update_attrs)
      assert todo.done == false
      assert todo.priority == 43
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end

    test "get_recommended/1 returns the recommended todo" do
      todo = todo_fixture(%{done: false, priority: 1})
      assert [todo] |> Todos.get_recommended() == todo

      sec_todo = todo_fixture(%{done: false, priority: 2})

      # to avoid flaky test I will only check if the returned todo is one of the two
      selected = [todo, sec_todo] |> Todos.get_recommended()
      assert todo == selected || sec_todo == selected

      assert Todos.get_recommended([]) == nil

      list = 1..2 |> Enum.map(fn _ -> todo_fixture(%{done: false, priority: 0}) end)
      selected = Todos.get_recommended(list)
      assert selected == list |> List.first() || selected == list |> List.last()
    end

    @tag :skip
    test "get_recommended/1 follow the avg of recommendations" do
      # - *Prepare lunch* (priority: `20`)
      # - *Water flowers* (priority: `50`)
      # - *Shop groceries* (priority: `60`)
      # - *Buy new flower pots* (priority: `130`)

      list = [
        todo_fixture(%{done: false, priority: 20, title: "Prepare lunch"}),
        todo_fixture(%{done: false, priority: 50, title: "Water flowers"}),
        todo_fixture(%{done: false, priority: 60, title: "Shop groceries"}),
        todo_fixture(%{done: false, priority: 130, title: "Buy new flower pots"})
      ]

      1..10_000
      |> Enum.map(fn _ -> list |> Todos.get_recommended() end)
      |> Enum.frequencies()
      |> Enum.map(fn {%Todo{} = todo, count} -> {todo.priority, count} end)
      |> dbg

      # [{20, 5345}, {50, 2123}, {60, 1715}, {130, 817}]
      # [{20, 5263}, {50, 2109}, {60, 1800}, {130, 828}]
      # [{20, 5380}, {50, 2144}, {60, 1661}, {130, 815}]
      #  [{20, 5246}, {50, 2162}, {60, 1760}, {130, 832}]
      # [{20, 5305}, {50, 2074}, {60, 1808}, {130, 813}]
    end
  end
end
