defmodule Blacksmith do
  defmacro __using__(_) do
    quote do
      import Blacksmith
      alias Blacksmith.Sequence
      @default_type :struct
      
      @new_function &Blacksmith.new/2
      @save_one_function &Blacksmith.saved/2
      @save_all_function &Blacksmith.new_saved_list/2
      
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
    new_opts
  end
  
  
  defmacro register name, options do
    quote do
      def unquote(name)(overrides \\ %{}, havings \\ %{}) do
        @new_function.( unquote(options), Dict.merge( overrides, havings ))
      end
      
      def unquote(:"saved_#{name}")(repo, overrides \\ %{}, havings \\ %{}) do
        new_saved( repo, 
                   unquote(options), 
                   Dict.merge( overrides, havings ), 
                   ( @save_one_function || &Blacksmith.saved/2 ), 
                   @new_function )
      end
      
      def unquote(:"#{name}_list")(number_of_records, overrides \\ %{}, havings \\ %{}) do
        new_list( number_of_records, fn -> unquote(options) end, Dict.merge( overrides, havings ), @new_function )
      end
      
      def unquote(:"saved_#{name}_list")(repo, number_of_records, overrides  \\ %{}, havings \\ %{}) do
        list = unquote(:"#{name}_list")(number_of_records, overrides, havings)
        @save_all_function.( repo, list )
      end
    end
  end
  
  def new([type: :blacksmith, prototype: prototype]=attributes, overrides) do
    stripped_attributes = 
      Dict.delete( attributes, :type ) 
      |> Dict.delete :prototype

    apply(Blacksmith, prototype, overrides) 
        
  end

  def new(attributes, overrides) do
    %{}
    |> Dict.merge( Dict.delete( attributes, :type )  )
    |> Dict.merge( overrides )
  end
  
  def new_saved(repo, attributes, overrides, save_function, new_function) do
    new_function.(attributes, overrides)
    |> save_function.( repo )
  end
  
  def saved(_map, _repo) do
    raise "Save not configured. See readme.md for details. "
  end
  
  def new_list(number_of_records, attributes, overrides, new_function) do
    Enum.map (1..number_of_records), &( new_function.(attributes.(), overrides) || &1)
  end
  
  def new_saved_list(_repo, _list) do
    raise "Save not configured. See readme.md for details. "
  end
  
  
end
