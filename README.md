blacksmith
==========

Data generation framework for Elixir.

In testing, sometimes it's useful to create records in the form of maps. Blacksmith makes it easy.

First, install Blacksmith:

Right now, you'll use mix with a git dependency. In your mix.exs file, add the blacksmith dependency:

~~~elixir
def deps do
  [{:blacksmith, git: "git://github.com/batate/blacksmith.git"}]
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
defmodule do Blacksmith.Config
  def save(repo, model) do
    repo |> save( model )
  end

  def save_all(repo, list_of_models) do
    repo |> save_all( list_of_models )
  end
end
~~~

Next, perhaps in test_helper for convenience or somewhere in lib for speed, register each of your new models with Forge. Use [Faker](https://github.com/igas/faker) for fake values, and sequences to maintain unique values:

~~~elixir
defmodule Forge do
  use Blacksmith
  register :user,
    name: Faker.Name.first_name,
    type: :map,
    email: Sequence.next(:email, &"test#{&1}@example.com"),
    description: Faker.Lorem.sentence,
    roles: [],
    always_the_same: "string"

  # this will create a user with roles set to [:admin]
  register :admin,
    type: :blacksmith,
    prototype: user,
    roles: ["admin"]
end
~~~

Now you can create a user, generating all of the default values:

~~~elixir
  user = Forge.user
~~~

or a saved user, with the name attribute overridden, and a new attribute of favorite_language:

~~~elixir
  user = Forge.saved_user Models.User, name: "Will Override", favorite_language: "Elixir"
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

Next release: allow nesting of having blacks.
