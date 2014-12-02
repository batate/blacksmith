defmodule Blacksmith.App do
  use Application

  def start(_type, _args), do: Blacksmith.Sequence.start_link
end
