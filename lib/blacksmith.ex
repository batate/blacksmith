defmodule Blacksmith do
  defmacro __using__(_) do
    quote do
      import Blacksmith, except: [having: 2]
      alias Blacksmith.Sequence
      @default_type :struct

      @new_function &Blacksmith.new/4
      @save_one_function &Blacksmith.saved/1
      @save_all_function &Blacksmith.new_saved_list/1

      defmacro having(opts, block) do
        Blacksmith.having(opts, block, __ENV__, __CALLER__)
      end
    end
  end

  def append_opts(opts_var, true, new_opts) do
    quote do: unquote(opts_var) ++ unquote(new_opts)
  end

  def append_opts(_, false, new_opts) do
    new_opts
  end

  # Allow a common set of arguments
  def having(opts, [do: block], env, caller) do
    opts_var = quote do: opts_var

    block =
      Macro.prewalk(block, fn
        {{:., _, [{:__aliases__, _, _}, :having]}, _, _} = ast ->
          ast
        {{:., _, [{:__aliases__, _, _} = alias, _]} = function, meta3, args} = ast ->
        if Macro.expand(alias, caller) == env.module do
          {function, meta3, args ++ [opts_var]}
        else
          ast
        end
        ast ->
          ast
      end)

    var_defined? = {:opts_var, env.module} in caller.vars
    opts = Blacksmith.append_opts(opts_var, var_defined?, opts)

    quote do
      opts_var = unquote(opts)
      context = unquote(block)
      opts_var = []
      context
    end
  end

  defmacro register(name, opts \\ [], fields) do
    name_attributes = :"#{name}_attributes"
    name_opts = :"#{name}_opts"

    quote do
      def unquote(name_attributes)() do
        unquote(fields)
      end

      def unquote(name_opts)() do
        unquote(opts)
      end

      def unquote(name)(overrides \\ %{}, havings \\ %{}) do
        @new_function.(unquote(name_attributes)(),
                       Blacksmith.merge(overrides, havings),
                       __MODULE__,
                       unquote(name_opts)())
      end

      def unquote(:"saved_#{name}")(overrides \\ %{}, havings \\ %{}) do
        new_saved(unquote(name_attributes)(),
                  Blacksmith.merge(overrides, havings),
                  __MODULE__,
                  unquote(name_opts)(),
                  @new_function,
                  @save_one_function)
      end

      def unquote(:"#{name}_list")(number_of_records, overrides \\ %{}, havings \\ %{}) do
        new_list(number_of_records,
                 &(unquote(Macro.var(name_attributes, nil))/0),
                 Blacksmith.merge(overrides, havings),
                 __MODULE__,
                 unquote(name_opts)(),
                 @new_function)
      end

      def unquote(:"saved_#{name}_list")(number_of_records, overrides \\ %{}, havings \\ %{}) do
        list = unquote(:"#{name}_list")(number_of_records, overrides, havings)
        @save_all_function.(list)
      end
    end
  end

  def new(attributes, overrides, module, opts) do
    map = if prototype = opts[:prototype] do
      apply(module, prototype, []) |> to_map
    else
      %{}
    end

    attributes = to_map(attributes)
    overrides  = to_map(overrides)

    if Map.has_key?(map, :__struct__) and Map.has_key?(attributes, :__struct__) do
      raise "prototype and current record cannot both be structs"
    end

    map
    |> Map.merge(attributes)
    |> Map.merge(overrides)
  end

  def new_saved(attributes, overrides, module, opts, new, save) do
    model = new.(attributes, overrides, module, opts)
    save.(model)
  end

  def saved(_map) do
    raise "Save not configured. See readme.md for details."
  end

  def new_list(number_of_records, attributes_fun, overrides, module, opts, new) do
    Enum.map(1..number_of_records, fn _ -> new.(attributes_fun.(), overrides, module, opts) end)
  end

  def new_saved_list(_list) do
    raise "Save not configured. See readme.md for details."
  end

  def to_map(list) when is_list(list),
    do: Enum.into(list, %{})
  def to_map(map) when is_map(map),
    do: map

  def merge(left, right) do
    Map.merge(to_map(left), to_map(right))
  end
end
