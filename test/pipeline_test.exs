defmodule Plumbery.PipelineTest do
  use ExUnit.Case

  defmodule Pipelines do
    use Plumbery
    import Plumbery.Request

    defp success_42(req), do: success(req, 42)
    def success_true(req), do: success(req, true)
    defp success_nil(req), do: success(req, nil)

    defp error_42(req), do: error(req, 42)
    def error_true(req), do: error(req, true)
    defp error_nil(req), do: error(req, nil)

    pipeline :empty_pipeline
    pipeline :empty_pipeline_unwrap, unwrap: true

    pipeline :one do
      pipe :success_42
    end

    pipeline :two do
      pipe :success_42
      pipe :success_true
    end

    pipeline :three do
      pipe :success_42
      pipe :success_true
      pipe :success_nil
    end

    pipeline :one_error do
      pipe :success_42
      pipe :error_42
      pipe :success_nil
    end

    pipeline :two_error do
      pipe :success_42
      pipe :error_true
      pipe :error_42
      pipe :success_nil
    end

    pipeline :three_error do
      pipe :success_42
      pipe :error_nil
      pipe :error_true
      pipe :error_42
      pipe :success_nil
    end

    pipeline :one_unwrap do
      unwrap true
      pipe :success_42
    end

    pipeline :two_unwrap do
      unwrap true
      pipe :success_42
      pipe :success_true
    end

    pipeline :one_error_unwrap do
      unwrap true
      pipe :success_42
      pipe :error_42
      pipe :success_nil
    end

    pipeline :two_error_unwrap do
      unwrap true
      pipe :success_42
      pipe :error_true
      pipe :error_42
      pipe :success_nil
    end
  end

  describe "pipeline:" do
    test "empty pipeline returns the argument" do
      req = %Plumbery.Request{command: %{watever: 12}}
      res = Pipelines.empty_pipeline(req)
      ^res = req
    end

    test "empty pipeline can unwrap" do
      req = %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}
      res = Pipelines.empty_pipeline_unwrap(req)
      ^res = req.result
    end

    test "returns result of last pipe" do
      req = %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}
      %Plumbery.Request{result: {:ok, 42}} = Pipelines.one(req)
      %Plumbery.Request{result: {:ok, true}} = Pipelines.two(req)
      %Plumbery.Request{result: {:ok, nil}} = Pipelines.three(req)
    end

    test "returns error from first failed pipe" do
      req = %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}
      %Plumbery.Request{result: {:error, 42}} = Pipelines.one_error(req)
      %Plumbery.Request{result: {:error, true}} = Pipelines.two_error(req)
      %Plumbery.Request{result: {:error, nil}} = Pipelines.three_error(req)
    end

    test "non-empty pipeline can unwrap" do
      req = %Plumbery.Request{command: %{watever: 12}, result: {:ok, :all_good}}
      {:ok, 42} = Pipelines.one_unwrap(req)
      {:ok, true} = Pipelines.two_unwrap(req)
      {:error, 42} = Pipelines.one_error_unwrap(req)
      {:error, true} = Pipelines.two_error_unwrap(req)
    end
  end
end
