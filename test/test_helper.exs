ExUnit.start(formatters: [ShouldI.CLIFormatter])
Blacksmith.Fake.start_link()
defmodule Forge do
  use Blacksmith
  alias Blacksmith.Fake
  
  register :user, 
    name: "John Henry", 
    email: Fake.email, 
    password: Fake.password
  
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
