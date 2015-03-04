defmodule Blacksmith do
  defmacro __using__(_) do
    quote do
      import Blacksmith
      alias Blacksmith.Sequence
      @default_type :struct

      @new_function &Blacksmith.new/4
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

        var_defined? = {:opts_var, __MODULE__} in __CALLER__.vars
        opts = Blacksmith.append_opts(opts_var, var_defined?, opts)

        quote do
          opts_var = unquote(opts)
          context = unquote(block)
          opts_var = []
          context
        end
      end

    end
  end

  def append_opts(opts_var, true, new_opts) do
    quote do: unquote(opts_var) ++ unquote(new_opts)
  end

  def append_opts(_, false, new_opts) do
    new_opts
  end

  defmacro register(name, opts \\ [], fields) do
    quote do
      def unquote(name)(overrides \\ %{}, havings \\ %{}) do
        @new_function.(unquote(fields),
                       Dict.merge(overrides, havings),
                       __MODULE__,
                       unquote(opts))
      end

      def unquote(:"saved_#{name}")(repo, overrides \\ %{}, havings \\ %{}) do
        new_saved(repo,
                  unquote(fields),
                  Dict.merge(overrides, havings),
                  __MODULE__,
                  unquote(opts),
                  (@save_one_function || &Blacksmith.saved/2),
                  @new_function)
      end

      def unquote(:"#{name}_list")(number_of_records, overrides \\ %{}, havings \\ %{}) do
        new_list(number_of_records,
                 unquote(fields),
                 Dict.merge(overrides, havings),
                 __MODULE__,
                 unquote(opts),
                 @new_function)
      end

      def unquote(:"saved_#{name}_list")(repo, number_of_records, overrides \\ %{}, havings \\ %{}) do
        list = unquote(:"#{name}_list")(number_of_records, overrides, havings)
        @save_all_function.( repo, list )
      end
    end
  end

  def new(attributes, overrides, module, opts) do
    if prototype = opts[:prototype] do
      map = apply(module, prototype, [])
    else
      map = %{}
    end

    map = map
          |> Map.merge(to_map(attributes))
          |> Map.merge(to_map(overrides))

    case Map.fetch(map, :__struct__) do
      {:ok, struct} ->
        map = Map.delete(map, :__struct__)
        struct(struct, map)
      :error ->
        map
    end
  end

  def new_saved(repo, attributes, overrides, module, opts, save_function, new_function) do
    model = new_function.(attributes, overrides, module, opts)
    save_function.(repo, model)
  end

  def saved(_map, _repo) do
    raise "Save not configured. See readme.md for details. "
  end

  def new_list(number_of_records, attributes, overrides, module, opts, new_function) do
    Enum.map((1..number_of_records), &(new_function.(attributes, overrides, module, opts) || &1))
  end

  def new_saved_list(_repo, _list) do
    raise "Save not configured. See readme.md for details. "
  end

  def to_map(list) when is_list(list),
    do: Enum.into(list, %{})
  def to_map(map) when is_map(map),
    do: map
end
