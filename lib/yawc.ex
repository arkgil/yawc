defmodule YAWC do
  @moduledoc """
  Yet Another Wrapper Compiler

  See documentation for `wrap/1` macro for the fun stuff.
  """

  @typep func :: {name :: atom(), arity()}

  @doc """
  Defines functions delegating calls to all public functions of the given module

  With respect to Elixir convention it ignores functions starting with `__`.

  ## Example

      defmodule Wrapped do
        def public_fun(), do: :value
      end

      defmodule Wrapping do
        import YAWC
        wrap Wrapped
      end

      iex> Wrapping.public_fun()
      :value

  Pure awesomeness. Now go, and use the wrapped module directly ;)
  """
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

      for {name, arity} <- functions do
        args = for i <- 0..arity, i > 0, do: Macro.var(:"#{i}", nil)

        quote do
          defdelegate unquote(name)(unquote_splicing(args)), to: unquote(module)
        end
      end
    rescue
      _ in UndefinedFunctionError ->
        raise ArgumentError, "Module #{inspect(module)} is unavailable"
    end
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
