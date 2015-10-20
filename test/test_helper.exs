ExUnit.start(formatters: [ShouldI.CLIFormatter])
defmodule Forge do
  use Blacksmith
  @save_one_function &Blacksmith.Config.save/1
  @save_all_function &Blacksmith.Config.save_all/1

  register :user,
    name: "John Henry",
    email: Sequence.next(:email, &"jh#{&1}@example.com")

  register :admin,
    [prototype: :user],
    roles: ["admin"]
end

defmodule JsonForge do
  use Blacksmith

  @new_function &Blacksmith.Config.new_json/2

  register :user,
    name: "John Henry",
    email: Faker.Internet.email
end

defmodule Blacksmith.Config do
  # this would normally be an API for persisting the new map to the repo
  def save(map), do: map
  def save_all(map_list), do: map_list
  def new_json(attributes, overrides) do
    %{}
    |> Dict.merge(Dict.delete(attributes, :type))
    |> Dict.merge(overrides)
    |> Poison.Encoder.encode([])
  end

end
