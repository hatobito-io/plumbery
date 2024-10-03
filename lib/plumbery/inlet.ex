defmodule Plumbery.Inlet do
  @moduledoc false
  defstruct pipeline: nil,
            request: nil,
            fields: nil,
            use_context: false,
            signature: nil,
            name: nil,
            when: [],
            args: [],
            arg_names: []

  @doc false
  defmacro compile(inlet, module) do
    quote bind_quoted: [inlet: inlet, module: module] do
      command =
        quote do
          %{}
        end

      make_command =
        Enum.reduce(inlet.arg_names, command, fn arg, command ->
          var = Macro.var(arg, nil)

          quote do
            Map.put(unquote(command), unquote(arg), unquote(var))
          end
        end)

      make_context =
        if inlet.use_context do
          Macro.var(:context, nil)
        else
          quote do
            nil
          end
        end

      args = if inlet.use_context, do: inlet.args ++ [Macro.var(:context, nil)], else: inlet.args

      signature =
        quote do
          unquote(inlet.name)(unquote_splicing(args))
        end

      signature =
        Enum.reduce(inlet.when, signature, fn w, signature ->
          quote do
            unquote(signature) when unquote(w)
          end
        end)

      pipeline_call =
        case inlet.pipeline do
          {mod, fun} ->
            quote do
              unquote(mod).unquote(fun)()
            end

          fun ->
            quote do
              unquote(fun)()
            end
        end

      def unquote(signature) do
        %unquote(inlet.request){
          command: unquote(make_command),
          context: unquote(make_context)
        }
        |> unquote(pipeline_call)
      end
    end
  end
end
