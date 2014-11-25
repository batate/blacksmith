defmodule Blacksmith do
  defmacro __using__(_) do
    quote do
      import Blacksmith
      @default_type :struct
      
      # Allow a common set of arguments
      defmacro having(opts, [do: block]) do
        opts_var = quote do: opts_var
  
        block = 
          Macro.prewalk(block, fn
            {{:., _, [{:__aliases__, _, _}, :having]}, _, _} = ast -> 
              ast
            {{:., _, [{:__aliases__, _, _} = alias, _]} = function, meta3, args} = ast ->
              if Macro.expand(alias, __CALLER__) == __MODULE__ do
                {function, meta3, args ++ [opts_var]}
              else
                ast
              end
            ast ->
              ast
          end)
          IO.inspect __CALLER__.vars
        quote do
          opts_var = unquote( Blacksmith.append_opts( __MODULE__, ( Dict.has_key? __CALLER__.vars, :opts_var ), opts) )
          unquote(block)
        end
      end

    end
  end

  def append_opts(module, true, new_opts) do
    quote do
      unquote(Macro.var(:opts_var, module)) ++ unquote(new_opts)
    end
  end

  def append_opts(_, false, new_opts) do
    IO.puts "Interior: new_opts is #{inspect new_opts}"
    new_opts
  end
  
  
  defmacro register name, options do
    quote do
      def unquote(name)(overrides \\ %{}, havings \\ %{}) do
        new unquote(options), Dict.merge( overrides, havings )
      end
      
      def unquote(:"saved_#{name}")(repo, overrides \\ %{}, havings \\ %{}) do
        new_saved repo, unquote(options), Dict.merge( overrides, havings )
      end
      
      def unquote(:"#{name}_list")(number_of_records, overrides \\ %{}, havings \\ %{}) do
        new_list( number_of_records, fn -> unquote(options) end, Dict.merge( overrides, havings ) )
      end
      
      def unquote(:"saved_#{name}_list")(repo, number_of_records, overrides  \\ %{}, havings \\ %{}) do
        new_saved_list( repo, number_of_records, fn -> unquote(options) end, Dict.merge( overrides, havings ) )
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
