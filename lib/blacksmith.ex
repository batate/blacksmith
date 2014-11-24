defmodule Blacksmith do
  defmacro __using__(_) do
    quote do
      import Blacksmith
      @default_type :struct
    end
  end
  
  
  defmacro register name, options do
    quote do
      def unquote(name)(overrides \\ %{}) do
        new unquote(options), overrides
      end
      
      def unquote(:"saved_#{name}")(repo, overrides \\ %{}) do
        new_saved repo, unquote(options), overrides
      end
      
      def unquote(:"#{name}_list")(number_of_records, overrides \\ %{}) do
        new_list( number_of_records, fn -> unquote(options) end, overrides )
      end
      
      def unquote(:"saved_#{name}_list")(repo, number_of_records, overrides  \\ %{}) do
        new_saved_list( repo, number_of_records, fn -> unquote(options) end, overrides )
      end
    end
  end
  
  def new([type: :blacksmith, prototype: prototype]=attributes, overrides) do
    stripped_attributes = Dict.delete( attributes, :type ) 
                    |> Dict.delete :prototype

    Dict.merge %{}, apply(Blacksmith, prototype) 
    |> Dict.merge( stripped_attributes )
        
  end

  def new(attributes, overrides) do
    stripped_attributes = Dict.delete( attributes, :type ) 

    %{}
    |> Dict.merge( stripped_attributes )
    |> Dict.merge( overrides )
  end
  
  def new_saved(repo, attributes, overrides) do
    new(attributes, overrides)
    |> saved( repo )
  end
  
  def saved(map, repo) do
    Blacksmith.Config.save(repo, map)
  end
  
  def new_list(number_of_records, attributes, overrides) do
    Enum.map (1..number_of_records), &( new(attributes.(), overrides) || &1)
  end
  
  def new_saved_list(repo, number_of_records, attributes, overrides) do
    Blacksmith.Config.save_all(repo, new_list(number_of_records, attributes, overrides))
  end
  
end
