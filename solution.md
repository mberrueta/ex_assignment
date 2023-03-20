# MBerrueta

## Set up

```sh
asdf install erlang 25.2.3
mix setup
```

## Research

```sh
# First understand the endpoints
mix phx.routes
# GET     /                                      ExAssignmentWeb.PageController :home
# PUT     /todos/:id/check                       ExAssignmentWeb.TodoController :check
# PUT     /todos/:id/uncheck                     ExAssignmentWeb.TodoController :uncheck
# GET     /todos                                 ExAssignmentWeb.TodoController :index
# GET     /todos/:id/edit                        ExAssignmentWeb.TodoController :edit
# GET     /todos/new                             ExAssignmentWeb.TodoController :new
# GET     /todos/:id                             ExAssignmentWeb.TodoController :show
# POST    /todos                                 ExAssignmentWeb.TodoController :create
# PATCH   /todos/:id                             ExAssignmentWeb.TodoController :update
# PUT     /todos/:id                             ExAssignmentWeb.TodoController :update
# DELETE  /todos/:id                             ExAssignmentWeb.TodoController :delete

# check model
ls priv/repo/migrations | grep exs

# ok, single model at the db, let's check the columns/indexes
ls priv/repo/migrations | pbcopy
cat priv/repo/migrations/20230308090956_create_todos.exs

# I like to start with test, checking if everything works as expected, and
# go thought it to understand the use cases
mix test

# let's run it
mix phx.server

open http://localhost:4000
# play a bit, add/check etc


```

## Found bugs/improvements

- allow a negative priority [IMPORTANT]
- lack if test for recommendations [IMPORTANT]
- credo could be good to analyze a bit the code [MEDIUM]
- test fixture can use `ex_machina` to generate more random data [LOW]
- tests can use `excoveralls` [LOW]
- single user [LOW]

## Exercise 1

Improve the random selection, in order to use the priority.
The number (since the lower is the highest) is the probability of not being selected.

So `A: 20` and `B: 80` means that `A should have the 0.8 selected chance, and B a 0.2`

First, we need to calculate the total of priority points. `total = SUM(all)`
Second calculate the probability of element `total * x/100 = points` -> `x = points * 100 / total`
Then calculate the reciprocal probability (because is inverted) `rP(a) = 1 / P(a)` and again the probability (now inverted) `new_total = sum(all)` ... `x = points * 100 / new_total`
Lastly the accumulated probability `each x, prob -> {x, prob + prob-previous}`

In the example

- a:  *Prepare lunch* (priority: `20`)
- b: *Water flowers* (priority: `50`)
- c: *Shop groceries* (priority: `60`)
- d: *Buy new flower pots* (priority: `130`)

The implementations is in `Todos.get_recommended()`

In the current implementation:

```elixir
# controller calls
open_todos = Todos.list_todos(:open)
done_todos = Todos.list_todos(:done)
recommended_todo = Todos.get_recommended()
```

```elixir
# list_todos is called twice. so could be passed as param
  def get_recommended() do
    list_todos(:open)
    |> case do
      [] -> nil
      todos -> Enum.take_random(todos, 1) |> List.first()
    end
  end
```
