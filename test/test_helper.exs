ExUnit.start(formatters: [ShouldI.CLIFormatter])
defmodule Forge do
  use Blacksmith
  
  register :user, 
    name: "John Henry", 
    email: Faker.Internet.email
  
  register :admin, 
    type: :blacksmith, 
    prototype: :user, 
    roles: ["admin"]
end

defmodule Blacksmith.Config do
  # this would normally be an API for persisting the new map to the repo
  def save( _, map ), do: map
  def save_all( _, map_list ), do: map_list
end
