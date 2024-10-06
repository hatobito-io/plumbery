defmodule Plumbery.Pipeline do
  @moduledoc false

  defstruct pipes: [],
            name: nil,
            doc: nil,
            unwrap: false,
            private: false,
            inlets: [],
            file_line: nil

  @doc false
  defmacro compile(pipeline) do
    docs = pipeline_docs(pipeline)

    quote bind_quoted: [pipeline: pipeline, docs: docs] do
      pipes = pipeline.pipes
      len = length(Enum.filter(pipes, &match?(%Plumbery.Pipe{}, &1)))
      name = pipeline.name
      first_name = :"_plumbery_#{pipeline.name}_0"

      pipes
      |> Enum.reduce({true, 0}, fn pipe, {escape_on_error, index} ->
        case pipe do
          %Plumbery.Pipe{} ->
            Plumbery.Pipeline.step(pipeline, pipe, index, index == len - 1, escape_on_error)
            {escape_on_error, index + 1}

          %Plumbery.EscapeOnError{} ->
            {pipe.escape, index}
        end
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
  defmacro step(pipeline, pipe, index, last, escape_on_error) do
    quote bind_quoted: [
            pipeline: pipeline,
            index: index,
            last: last,
            pipe: pipe,
            escape_on_error: escape_on_error
          ] do
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

      if escape_on_error do
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
end
