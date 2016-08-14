Blacksmith
==========

Data generation framework for Elixir.

In testing, sometimes it's useful to create records in the form of maps. Blacksmith makes it easy.

First, install Blacksmith:

In your mix.exs file, add the blacksmith dependency:

~~~elixir
def deps do
  [{:blacksmith, "~> 0.1"}]
end
~~~

You will also have to add `:blacksmith` to your application list:

~~~elixir
def application do
  [applications: applications(Mix.env)]
end

defp applications(:test), do: applications(:all) ++ [:blacksmith]
defp applications(_all),  do: [:logger]
~~~

Next, tell Blacksmith how to save one record, or many records:

~~~elixir
defmodule Blacksmith.Config do
  def save(model) do
    MyRepo |> save(model)
  end

  def save_all(list_of_models) do
    MyRepo |> save_all(list_of_models)
  end
end
~~~

Next, perhaps in test_helper for convenience or somewhere in lib for speed, register each of your new models with Forge. Use [Faker](https://github.com/igas/faker) for fake values, and sequences to maintain unique values:

~~~elixir
defmodule Forge do
  use Blacksmith
  register :user,
    name: Faker.Name.first_name,
    email: Sequence.next(:email, &"test#{&1}@example.com"),
    description: Faker.Lorem.sentence,
    roles: [],
    always_the_same: "string"

  # this will create a user with roles set to [:admin]
  register :admin,
    [prototype: :user],
    roles: ["admin"]
end
~~~

Now you can create a user, generating all of the default values:

~~~elixir
  user = Forge.user
~~~

or a saved user, with the name attribute overridden, and a new attribute of favorite_language:

~~~elixir
  user = Forge.saved_user
           name: "Will Override",
           favorite_language: "Elixir"
~~~

or a list of 5 users

~~~elixir
  user = Forge.user_list 5
~~~

or a saved list of 5 admins

~~~elixir
  admin = Forge.saved_admin_list repo, 5
~~~

Create a list using a few common data elements:

~~~elixir
  Forge.having survey_id: some_survey.id, author: Forge.user do
    question = Forge.question   # will share the same survey id and user from above
  end
~~~

Next release: allow nesting of having blocks.

## Using with Ecto

Blacksmith can be used easily with a database persistence library such as Ecto.

~~~elixir
defmodule User do
  use Ecto.Model

  schema "users" do
    field :name, :string
    field :email, :string
  end
end
~~~

The `@save_one_function` and `@save_all_function` attributes are used to delegate to your persistence layer. We delegate to `Blacksmith.Config` defined below. You'll also notice that we directly create a struct in `register :user`, that's because Ecto works with models built on structs instead of plain maps.

~~~elixir
defmodule Forge do
  use Blacksmith

  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  register :user, %User{
    name: "John Henry",
    email: Sequence.next(:email, &"jh#{&1}@example.com")
  }
end
~~~

`Blacksmith.Config` defines the callback functions that delegate to the Ecto repository for persistence.

~~~elixir
defmodule Blacksmith.Config do
  def save(map) do
    MyRepo.insert(map)
  end

  def save_all(list) do
    Enum.map(list, &MyRepo.insert/1)
  end
end
~~~

`Forge.saved_user` will generate a `User` model that have been inserted in the database backed by `MyRepo`.
