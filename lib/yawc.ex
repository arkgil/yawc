defmodule YAWC do
  @moduledoc """
  Yet Another Wrapper Compiler
  """

  @typep func :: {name :: atom(), arity()}

  defmacro wrap(module)
           when is_atom(module)
           when is_tuple(module) do
    module = Macro.expand(module, __CALLER__)

    if __CALLER__.module do
      :ok
    else
      raise ArgumentError, "YAWC.wrap/1 can't be invoked outside the module definition"
    end

    if __CALLER__.function do
      raise ArgumentError, "YAWC.wrap/1 can't be invoked inside the function definition"
    else
      :ok
    end

    try do
      # We need to catch error here. We can't use Code.ensure_loaded/compile/1 because
      # if the module is defined in the same file, it always returns an error.
      functions =
        module.module_info(:exports)
        |> filter_functions()

      quote bind_quoted: [module: module, functions: functions] do
        for function <- functions do
          defdelegate unquote(YAWC.__call_ast__(function)), to: module
        end
      end
    rescue
      _ in UndefinedFunctionError ->
        raise ArgumentError, "Module #{inspect(module)} is unavailable"
    end
  end

  ## Private exported

  @spec __call_ast__(func) :: Macro.t()
  def __call_ast__({name, 0}) do
    {name, [], []}
  end

  def __call_ast__({name, arity}) do
    {name, [], Enum.map(1..arity, fn i -> {:"#{i}", [], __ENV__.context} end)}
  end

  ## Internals

  @spec filter_functions([func]) :: [func]
  defp filter_functions(functions) do
    functions
    |> Enum.map(fn {name, arity} -> {to_string(name), arity} end)
    |> Enum.filter(&wrappable?/1)
    |> Enum.map(fn {name, arity} -> {String.to_atom(name), arity} end)
  end

  @spec wrappable?({String.t(), arity}) :: boolean
  defp wrappable?({"module_info", 0}), do: false
  defp wrappable?({"module_info", 1}), do: false
  defp wrappable?({"__" <> _, _}), do: false
  defp wrappable?({"MACRO-", _}), do: false
  defp wrappable?({_, _}), do: true
end
