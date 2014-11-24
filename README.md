blacksmith
==========

Data generation framework for Elixir. 

In testing, sometimes it's useful to create structs or saved records. Blacksmith makes it easy. 



First, install Blacksmith:
...

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
    name: fake(:name),                # use the igar/faker framework
    type: :struct, 
    email: fake(:email), 
    description: fake(:sentence, 2..5), 
    roles: [], 
    always_the_same: "string"
    
  # this will create a user with roles set to [:admin]
  register :admin, 
    type: :blacksmith_user,
    roles: ["admin"]
  
  register :company, 
    subdomain: &( "subdomain#{Blacksmith.unique_id}" )    # creates a unique subdomain, 
    name: fake(:sentence, 4..10)
    # picks up blacksmith default type


end

~~~

Now you can create a user, generating all of the default values:

~~~elixir
  user = Blacksmith.user
~~~

or a saved user:

~~~elixir
  user = Blacksmith.saved_user Models.User, name: "Will Override"
~~~

or a list of users

~~~elixir
  user = Blacksmith.
~~~

or a saved list of 5 admins

~~~elixir
  admin = Blacksmith.saved_admin_list repo, 5
~~~


You can create a list using a few common data elements:

~~~elixir
  Blacksmith.having survey_id: Blacksmith.survey.id, author: Blacksmith.user do
    question = Blacksmith.question   # will share the same survey id and user from above
  end
  
