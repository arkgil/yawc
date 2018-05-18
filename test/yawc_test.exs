defmodule YAWCTest do
  use ExUnit.Case

  describe "wrap/1" do
    test "raises an error when invoked outside the module definition" do
      code = """
      require YAWC
      YAWC.wrap(Wrapped)
      """

      assert_raise ArgumentError, fn ->
        Code.compile_string(code)
      end
    end

    test "raises an error when invoked inside the function definition" do
      code = """
      require YAWC
      defmodule Wrapping do
        def func() do
          YAWC.wrap(Wrapped)
        end
      end
      """

      assert_raise ArgumentError, fn ->
        Code.compile_string(code)
      end
    end

    test "raises an error when wrapped module doesn't exist" do
      wrapped = gen_module_name()
      wrapping = gen_module_name()

      code = """
      require YAWC
      defmodule #{wrapping} do
        YAWC.wrap(#{wrapped})
      end
      """

      assert_raise ArgumentError, fn ->
        Code.compile_string(code)
      end
    end

    test "wraps public functions from another module" do
      wrapped = gen_module_name()
      wrapping = gen_module_name()

      code = """
      defmodule #{wrapped} do
        def public_one(_a, _b), do: "public_one called"
        def public_two(_a, _b, _c), do: "public_two called"
      end


      defmodule #{wrapping} do
        require YAWC
        YAWC.wrap(#{wrapped})
      end
      """

      Code.compile_string(code)

      assert "public_one called" == module(wrapping).public_one(:what, :ever)
      assert "public_two called" == module(wrapping).public_two(:it, :doesnt, :matter)
    end

    test "doesn't wrap certain functions" do
      wrapped = gen_module_name()
      wrapping = gen_module_name()

      code = """
      defmodule #{wrapped} do
      defp private(), do: "private called"
      def __private(), do: "__\#{private()}"
      def __private__(), do: "__private__ called"
      end


      defmodule #{wrapping} do
        require YAWC
        YAWC.wrap(#{wrapped})
      end
      """

      Code.compile_string(code)

      functions = module(wrapping).module_info(:exports)
      refute Enum.member?(functions, {:private, 0})
      refute Enum.member?(functions, {:__private, 0})
      refute Enum.member?(functions, {:__private__, 0})
    end

    @tag :now
    test "wraps two modules if function names do not clash" do
      wrapped1 = gen_module_name()
      wrapped2 = gen_module_name()
      wrapping = gen_module_name()

      code = """
      defmodule #{wrapped1} do
        def public_one(), do: "public_one called"
      end

      defmodule #{wrapped2} do
        def public_two(), do: "public_two called"
      end


      defmodule #{wrapping} do
        require YAWC
        YAWC.wrap(#{wrapped1})
        YAWC.wrap(#{wrapped2})
      end
      """

      Code.compile_string(code)

      assert "public_one called" == module(wrapping).public_one()
      assert "public_two called" == module(wrapping).public_two()
    end
  end

  ## Helpers

  @spec gen_module_name() :: String.t()
  defp gen_module_name() do
    "WrapTestModule#{:erlang.unique_integer([:positive, :monotonic])}"
  end

  @spec module(name :: String.t()) :: module()
  defp module(name) do
    "Elixir.#{name}" |> String.to_atom()
  end
end
