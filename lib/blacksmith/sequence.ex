defmodule Blacksmith.Sequence do
  @moduledoc """
  Generate an series of incrementing, unique, numbers starting with 0.

  ## Example

      iex> Sequence.next
      0
      iex> Sequence.next
      1

  Pass an atom to name different sequences:

      iex> Sequence.next(:foo)
      0
      iex> Sequence.next(:foo)
      1
      iex> Sequence.next(:not_foo)
      0

  A function to format the number can be passed in as well:

      iex> Sequence.next(&"default#\{&1}@example.com")
      "default2@example.com"
      iex> Sequence.next(:email, &"email#\{&1}@example.com")
      "email0@example.com"

  This is extremely useful when your Forge model's persistance layer has unique validations:

      defmodule Forge do
        use Blacksmith

        register :user,
          name:  Faker.name,
          email: Sequence.next(:email, &"email#\{&1}@example.com")
      end

  """

  @doc false
  def start_link, do: Agent.start_link(&HashDict.new/0, name: __MODULE__)

  @doc "Generate the default sequence (:default)"
  def next, do: next(:default)

  @doc "Generate and format the default sequence"
  def next(formatter) when is_function(formatter), do: next(:default, formatter)

  @doc "Generate a named sequence"
  def next(name) do
    Agent.get_and_update __MODULE__, fn(seqs) ->
      current = HashDict.get(seqs, name, 0)
      next    = HashDict.put(seqs, name, current + 1)
      {current, next}
    end
  end

  @doc "Generate and format a named sequence"
  def next(name, formatter), do: name |> next |> formatter.()
end
