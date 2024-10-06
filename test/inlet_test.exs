defmodule Plumbery.InletTest do
  alias Plumbery.InletTest.Inlets.Command
  use ExUnit.Case

  defmodule Inlets do
    defmodule Command do
      defstruct x: nil, y: nil
    end

    defmodule Request do
      use Plumbery.Request
    end

    use Plumbery
    import Plumbery.Request
    def success1(req), do: success(req, 1)

    pipeline :pipeline1 do
      private true
      pipe :success1
      inlet inlet_inline(x, y)
      inlet inlet_inline_command_struct(x, y), command: Command
      inlet inlet_inline_request_struct(x, y), request: Request
    end

    inlet inlet(x, y, 2222), pipeline: :pipeline1
    inlet inlet(x, y), pipeline: :pipeline1
    inlet inlet_command_struct(x, y), pipeline: :pipeline1, command: Command
    inlet inlet_request_struct(x, y), pipeline: :pipeline1, request: Request
    inlet inlet_default(x, y \\ 999), pipeline: :pipeline1

    inlet inlet_where(x, y \\ 999) when is_integer(y), pipeline: :pipeline1
    inlet inlet_where_2(x, y \\ 999) when is_integer(y) when is_boolean(y), pipeline: :pipeline1

    inlet inlet_with_context(x, y \\ 999) when is_integer(y) when is_boolean(y),
      pipeline: :pipeline1,
      use_context: true
  end

  describe "inlets:" do
    test "copy arguments to command" do
      %Plumbery.Request{command: %{x: 1, y: 2}, result: {:ok, 1}} = Inlets.inlet(1, 2)
      %Plumbery.Request{command: %{x: 3, y: 4}, result: {:ok, 1}} = Inlets.inlet_inline(3, 4)
      %Plumbery.Request{command: %{x: 3, y: 4}, result: {:ok, 1}} = Inlets.inlet(3, 4, 2222)

      %Plumbery.Request{command: %Command{x: 1, y: 2}, result: {:ok, 1}} =
        Inlets.inlet_command_struct(1, 2)

      %Plumbery.Request{command: %Command{x: 3, y: 4}, result: {:ok, 1}} =
        Inlets.inlet_inline_command_struct(3, 4)

      %Inlets.Request{command: %{x: 1, y: 2}, result: {:ok, 1}} =
        Inlets.inlet_request_struct(1, 2)

      %Inlets.Request{command: %{x: 3, y: 4}, result: {:ok, 1}} =
        Inlets.inlet_inline_request_struct(3, 4)
    end

    test "can have default params" do
      %Plumbery.Request{command: %{x: 1, y: 2}, result: {:ok, 1}} = Inlets.inlet_default(1, 2)
      %Plumbery.Request{command: %{x: 1, y: 999}, result: {:ok, 1}} = Inlets.inlet_default(1)
    end

    test "can have where clauses" do
      %Plumbery.Request{command: %{x: 1, y: 2}, result: {:ok, 1}} = Inlets.inlet_where(1, 2)
      %Plumbery.Request{command: %{x: 1, y: 2}, result: {:ok, 1}} = Inlets.inlet_where_2(1, 2)

      %Plumbery.Request{command: %{x: 1, y: true}, result: {:ok, 1}} =
        Inlets.inlet_where_2(1, true)

      assert_raise FunctionClauseError, fn ->
        Inlets.inlet_where(1, "NaN")
      end

      assert_raise FunctionClauseError, fn ->
        Inlets.inlet_where_2(1, nil)
      end
    end

    test "can accept context" do
      %Plumbery.Request{command: %{x: 1, y: 2}, result: {:ok, 1}, context: :system} =
        Inlets.inlet_with_context(1, 2, :system)

      %Plumbery.Request{command: %{x: 1, y: 999}, result: {:ok, 1}, context: :system} =
        Inlets.inlet_with_context(1, :system)
    end
  end
end
