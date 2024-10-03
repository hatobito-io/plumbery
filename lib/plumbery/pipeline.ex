defmodule Plumbery.Pipeline do
  @moduledoc false
  alias Plumbery.Pipeline

  defstruct pipes: [],
            name: nil,
            doc: nil,
            recovery_point: nil,
            unwrap: false,
            private: false,
            pipes_are_recovery_points: nil,
            inlets: [],
            file_line: nil

  @doc false
  defmacro compile(pipeline) do
    docs = pipeline_docs(pipeline)

    quote bind_quoted: [pipeline: pipeline, docs: docs] do
      pipes = pipeline.pipes
      len = length(pipes)
      name = pipeline.name
      first_name = :"_plumbery_#{pipeline.name}_0"

      Enum.with_index(pipes)
      |> Enum.each(fn {pipe, index} ->
        Plumbery.Pipeline.step(pipeline, pipe, index, index == len - 1)
      end)

      unwrap =
        if pipeline.unwrap do
          quote do
            Plumbery.Request.unwrap(req)
          end
        else
          quote do
            req
          end
        end

      body =
        if len > 0 do
          quote do
            req = unquote(first_name)(req)
            unquote(unwrap)
          end
        else
          quote do
            unquote(unwrap)
          end
        end

      @doc docs
      @spec unquote(name)(any()) :: any()
      if pipeline.private do
        defp unquote(name)(req) do
          unquote(body)
        end
      else
        def unquote(name)(req) do
          unquote(body)
        end
      end
    end
  end

  @doc false
  defmacro step(pipeline, pipe, index, last) do
    quote bind_quoted: [pipeline: pipeline, index: index, last: last, pipe: pipe] do
      name = :"_plumbery_#{pipeline.name}_#{index}"
      next_name = :"_plumbery_#{pipeline.name}_#{index + 1}"

      call =
        case pipe.function do
          {mod, fun} ->
            quote do
              unquote(mod).unquote(fun)(req)
            end

          fun ->
            quote do
              unquote(fun)(req)
            end
        end

      defp unquote(name)(%{halted?: true} = req), do: req

      recovery =
        [
          pipe.recovery_point,
          pipeline.pipes_are_recovery_points,
          Plumbery.Pipeline.pipe_is_recovery(__MODULE__, pipe)
        ]
        |> Enum.find(&(!is_nil(&1)))

      unless recovery do
        defp unquote(name)(%{result: {:error, _}} = req), do: req
      end

      if last do
        defp unquote(name)(req),
          do: unquote(call)
      else
        defp unquote(name)(req),
          do: unquote(next_name)(unquote(call))
      end
    end
  end

  defp pipeline_docs(pipeline) do
    quote bind_quoted: [pipeline: pipeline] do
      case pipeline.doc do
        nil ->
          quote do
            nil
          end

        doc ->
          quote do
            unquote(doc)
          end
      end
    end
  end

  @doc false
  def pipe_is_recovery(module, pipe) do
    function = pipe.function

    {mod, fun, remote} =
      case function do
        {mod, fun} -> {mod, fun, true}
        fun -> {module, fun, false}
      end

    compiled = !remote || Code.ensure_compiled(mod)

    exists =
      if remote,
        do: function_exported?(mod, fun, 1),
        else: Module.defines?(mod, {fun, 1})

    is_pipeline = is_pipeline(mod, fun)

    case {compiled, exists, is_pipeline} do
      {{:error, _}, _, _} ->
        IO.warn(
          "Module #{inspect(mod)} is not available. Either it does not exist or there is a circular dependency",
          pipe.file_line
        )

        false

      {_, false, _} ->
        IO.warn(
          "Function #{inspect(fun)} is not available",
          pipe.file_line
        )

        false

      {_, _, false} ->
        pipe.recovery_point

      {_, _, pipeline = %Pipeline{}} ->
        pipeline.recovery_point
    end
  end

  defp is_pipeline(module, func) do
    try do
      pipelines =
        Spark.Dsl.Extension.get_entities(module, [:plumbery])
        |> Enum.filter(&match?(%Plumbery.Pipeline{name: ^func}, &1))

      case pipelines do
        [] -> false
        [pipeline | _] -> pipeline
      end
    rescue
      e in ArgumentError ->
        if Regex.match?(~r/is not a Spark DSL module/, Exception.message(e)),
          do: false,
          else: reraise(e, __STACKTRACE__)
    end
  end
end
