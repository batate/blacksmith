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

Next, tell Blacksmith how to save one record, or many records:

~~~elixir
defmodule do Blacksmith.Config
  def save(repo, model) do
    model |> save
  end
  
  def save_all(repo, list_of_models) do
    list_of_models |> save_all
  end
end
~~~

Next, register each of your new models with Forge:

~~~elixir
defmodule Blacksmith.Forge do

  @default_type :struct       # :struct or :map

  # This will create a struct of User
  register :user, 
    name: Fake.name,          
    type: :map, 
    email: fake(:email), 
    description: fake(:sentence, 2..5), 
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

or a saved user:

~~~elixir
  user = Forge.saved_user Models.User, name: "Will Override"
~~~

or a list of 5 users

~~~elixir
  user = Forge.user_list 5
~~~

or a saved list of 5 admins

~~~elixir
  admin = Forge.saved_admin_list repo, 5
~~~


Next release: Create a list using a few common data elements:

~~~elixir
  Forge.having survey_id: some_survey.id, author: Forge.user do
    question = Forge.question   # will share the same survey id and user from above
  end
~~~

