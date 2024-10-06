defmodule Plumbery.EsapingTest do
  use ExUnit.Case

  defmodule Simple do
    import Plumbery.Request
    use Plumbery

    defp trace(req, call) do
      assigns = Map.update(req.assigns, :trace, [call], &(&1 ++ [call]))
      %{req | assigns: assigns}
    end

    defp error1(req), do: error(req, 1) |> trace(:error1)
    def error2(req), do: error(req, 2) |> trace(:error2)
    defp error3(req), do: error(req, 3) |> trace(:error3)

    defp success1(req), do: success(req, 1) |> trace(:success1)
    def success2(req), do: success(req, 2) |> trace(:success2)
    defp success3(req), do: success(req, 3) |> trace(:success3)

    pipeline :recover1 do
      pipe :error1
      escape_on_error false
      pipe :success1
    end

    pipeline :recover2 do
      pipe :error1
      escape_on_error false
      pipe :success1
      pipe :success2
    end

    pipeline :recover3 do
      pipe :error1
      escape_on_error false
      pipe :success1
      pipe :success2
      escape_on_error true
      pipe :error2
      pipe :success3
    end

    pipeline :recover_on_entry1 do
      escape_on_error false
      pipe :error1
    end

    pipeline :recover_on_entry2 do
      pipe :error1
    end

    pipeline :recover_all do
      escape_on_error false
      pipe :error1
      pipe :error2
      pipe :error3
      pipe :success1
      pipe :success2
      pipe :success3
    end

    pipeline :recover_all_with_non_default do
      escape_on_error false
      pipe :error1
      pipe :error2
      pipe :error3
      escape_on_error true
      pipe :success1
      pipe :success2
      pipe :success3
    end

    pipeline :nested_recovery do
      escape_on_error false
      pipe :success1
    end

    pipeline :recover_nested do
      pipe :error1
      escape_on_error false
      pipe :nested_recovery
    end
  end

  describe "recovery:" do
    test "recovery points are called" do
      req =
        %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}

      %Plumbery.Request{result: {:ok, 1}, assigns: %{trace: [:error1, :success1]}} =
        Simple.recover1(req)

      %Plumbery.Request{result: {:ok, 2}, assigns: %{trace: [:error1, :success1, :success2]}} =
        Simple.recover2(req)

      %Plumbery.Request{
        result: {:error, 2},
        assigns: %{trace: [:error1, :success1, :success2, :error2]}
      } = Simple.recover3(req)
    end

    test "recovery points are called on entry" do
      req =
        %Plumbery.Request{command: %{watever: 12}, result: {:error, :all_bad}}
        |> Plumbery.Request.assign(:trace, [])

      %Plumbery.Request{result: {:error, 1}, assigns: %{trace: [:error1]}} =
        Simple.recover_on_entry1(req)

      %Plumbery.Request{result: {:error, :all_bad}, assigns: %{trace: []}} =
        Simple.recover_on_entry2(req)
    end

    test "pipes_are_recovery_points" do
      req =
        %Plumbery.Request{command: %{watever: 12}, result: {:error, :all_bad}}
        |> Plumbery.Request.assign(:trace, [])

      %Plumbery.Request{
        result: {:ok, 3},
        assigns: %{trace: [:error1, :error2, :error3, :success1, :success2, :success3]}
      } =
        Simple.recover_all(req)

      %Plumbery.Request{
        result: {:error, 3},
        assigns: %{trace: [:error1, :error2, :error3]}
      } =
        Simple.recover_all_with_non_default(req)
    end

    test "nested pipe as recovery point" do
      req =
        %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}
        |> Plumbery.Request.assign(:trace, [])

      %Plumbery.Request{
        result: {:ok, 1},
        assigns: %{trace: [:error1, :success1]}
      } =
        Simple.recover_nested(req)
    end
  end
end
