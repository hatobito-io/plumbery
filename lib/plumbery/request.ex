defmodule Plumbery.Request do
  @moduledoc """

  Requests hold shared state and execution result. As the request moves through
  the pipeline, it can be modified and later used in next steps down the
  pipeline. 

  Requests are expected to be structs with at least the following fields:

  * `command` is a map or struct that contains the arguments for pipeline
  * `context` contains information about calling
    context and can be used, for example, for authorization
  * `assigns` a map with shared state
  * `result` contains pipe execution result
  * `halted?` true if pipeline is halted

  ## Defining a request struct

  `Plumbery.Request` is a struct that can in many cases be used as a request for pipelines.
  In cases when you need additional fields in your requests, you can use `Plumbery.Request`
  to define the struct.

  To define a request struct, create a module and use `Plumbery.Request`,
  passing a keyword list with additional fields and their default values.

      defmodule MyApp.Request do
        @enforce_keys [:field1]
        use Plumbery.Request, field1: nil, field2: false
      end

  """

  defstruct command: nil, context: nil, result: nil, halted?: false, assigns: %{}

  @required_fields [command: nil, context: nil, result: nil, halted?: false, assigns: %{}]

  @type result() :: nil | {:error, any()} | {:ok, any()}

  @type t() :: %{
          :command => any(),
          :context => any(),
          :assigns => %{},
          :result => result(),
          :halted? => boolean(),
          optional(any()) => any()
        }

  @doc """
  Assigns a value to a key in the request's shared state map.
  """
  @spec assign(t(), atom(), term()) :: t()
  def assign(request, key, value), do: %{request | assigns: Map.put(request.assigns, key, value)}

  @doc """
  Sets result to `{:error, error}`. Further steps in the pipeline will not be
  executed except imediately following subsequent steps that are recovery
  points. If the recovery points  return success, execution continues,
  otherwise the pipeline ends. Calling `halt/1` after `error/2` will prevent
  recovery points from execution.
  """
  @spec error(t(), term()) :: t()
  def error(request, error), do: %{request | result: {:error, error}}

  @doc """
  Sets result to `{:ok, result}`. Further steps in the pipeline will be
  executed and can further modify the result.
  """
  @spec success(t(), term()) :: t()
  def success(request, result), do: %{request | result: {:ok, result}}

  @doc """
  Sets result to `res`. Further steps in the pipeline will be
  executed and can further modify the result.

  When `strict` is true (the default), only {:error, \\_} and {:ok, \\_} tuples are
  accepted, otherwise any value can be passed.

  result, not request, is the first argument intentionally. It allows for this
  type of calls:

  ```elixir
  some_function(req.command)
  |> result(req)
  ```
  """
  @spec result(any(), t(), boolean()) :: t()
  def result(res, req, strict \\ true) when is_boolean(strict) do
    case {strict, res} do
      {false, res} ->
        %{req | result: res}

      {true, {:ok, res}} ->
        %{req | result: {:ok, res}}

      {true, {:error, err}} ->
        %{req | result: {:error, err}}

      _ ->
        raise ArgumentError,
          message: "In strict mode, only  {:error, _} and {:ok, _} are accepted"
    end
  end

  @doc """
  Halts the pipeline. No further steps will be executed.
  """
  @spec halt(t()) :: t()
  def halt(request), do: %{request | halted?: true}

  @doc """
  Returns request's `result` field.
  """
  @spec unwrap(t()) :: result()
  def unwrap(request), do: request.result

  defmacro __using__(fields \\ []) when is_list(fields) do
    fields =
      Macro.escape(@required_fields ++ fields)

    quote do
      defstruct unquote(fields)
    end
  end

  @doc false
  def conforms(module) do
    case Code.ensure_compiled(module) do
      {:module, _} ->
        case module.__info__(:struct) do
          nil ->
            {:error, "#{inspect(module)} is not a struct"}

          fields ->
            missing =
              Enum.filter(@required_fields, fn {f, _} ->
                !Enum.find(fields, fn
                  %{field: ^f} -> true
                  _ -> false
                end)
              end)
              |> Enum.map(fn {f, _} -> Atom.to_string(f) end)

            case missing do
              [] ->
                :ok

              _ ->
                {:error,
                 "Struct %{#{inspect(module)}} is missing the foolowing field(s): #{Enum.join(missing, ", ")}"}
            end
        end

      _ ->
        {:error, "#{inspect(module)} is not compiled"}
    end
  end
end
