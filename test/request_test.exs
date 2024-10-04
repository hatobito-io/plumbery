defmodule Plumbery.BasicRequestTest do
  alias Plumbery.CustomRequest
  alias Plumbery.Request
  use ExUnit.Case

  defmodule BasicRequest do
    use Plumbery.Request
  end

  defmodule CustomRequest do
    use Plumbery.Request, field1: true, field2: 42
  end

  describe "basic request" do
    test "assigns values" do
      req =
        %BasicRequest{}
        |> Request.assign(:some_field, "value")

      %BasicRequest{assigns: %{some_field: "value"}} = req
    end

    test "halts pipeline" do
      req =
        %BasicRequest{}
        |> Request.halt()

      %BasicRequest{halted?: true} = req
    end

    test "sets error" do
      req =
        %BasicRequest{}
        |> Request.error("err")

      %BasicRequest{result: {:error, "err"}} = req
    end

    test "sets success" do
      req =
        %BasicRequest{}
        |> Request.success(42)

      %BasicRequest{result: {:ok, 42}} = req
    end

    test "sets result" do
      req = %BasicRequest{}
      %BasicRequest{result: {:ok, 42}} = {:ok, 42} |> Request.result(req)
      %BasicRequest{result: {:error, :bad}} = {:error, :bad} |> Request.result(req)
      %BasicRequest{result: 99} = 99 |> Request.result(req, false)

      assert_raise(ArgumentError, fn ->
        %BasicRequest{result: 99} = 99 |> Request.result(req)
      end)
    end
  end

  describe "custom request" do
    test "has_additional_fields" do
      req = %CustomRequest{}
      %CustomRequest{field1: true, field2: 42} = req
    end

    test "assigns values" do
      req =
        %CustomRequest{}
        |> Request.assign(:some_field, "value")

      %CustomRequest{assigns: %{some_field: "value"}} = req
    end

    test "halts pipeline" do
      req =
        %CustomRequest{}
        |> Request.halt()

      %CustomRequest{halted?: true} = req
    end

    test "sets error" do
      req =
        %CustomRequest{}
        |> Request.error("err")

      %CustomRequest{result: {:error, "err"}} = req
    end

    test "sets success" do
      req =
        %CustomRequest{}
        |> Request.success(42)

      %CustomRequest{result: {:ok, 42}} = req
    end

    test "sets result" do
      req = %CustomRequest{}
      %CustomRequest{result: {:ok, 42}} = {:ok, 42} |> Request.result(req)
      %CustomRequest{result: {:error, :bad}} = {:error, :bad} |> Request.result(req)
      %CustomRequest{result: 99} = 99 |> Request.result(req, false)

      assert_raise(ArgumentError, fn ->
        %CustomRequest{result: 99} = 99 |> Request.result(req)
      end)
    end
  end
end
