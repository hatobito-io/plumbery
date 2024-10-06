defmodule Plumbery do
  @moduledoc """
  Module `Plumbery` provides a DSL for building pipelines. 

  Basic concepts are as follows:

  * `request` is a struct that is passed beetween pipes
  * `pipe`  is a function that accepts a struct and returns a struct, normally
  of the same kind
  * `pipeline`  is a pipe composed of other pipes. The request moves through
  the pipeline one pipe at a time and each pipe has an opportunity to halt the
  pipeline. After a pipeline is halted, the request is returned from the
  pipeline without going through subsequent pipes in the pipeline
  * `inlet` is a function that accepts zero or more arguments and returns a
  request. Useful for API entry points that accept arbitrary arguments and
  convert them to a request 
  """
  require Plumbery.Inlet
  alias Plumbery.Inlet
  use Spark.Dsl, default_extensions: [extensions: [Plumbery.Dsl]]

  defmacro __using__(opts) do
    super(opts)
  end

  @impl Spark.Dsl
  def handle_before_compile(_) do
    quote do
      alias Plumbery.Pipeline
      alias Plumbery.Inlet
      require Plumbery.Pipeline
      require Plumbery.Inlet

      for reference <- Spark.Dsl.Extension.get_entities(__MODULE__, [:plumbery]) do
        case reference do
          %Pipeline{} ->
            Pipeline.compile(reference)

            for inlet <- reference.inlets do
              Inlet.compile(%{inlet | pipeline: reference.name}, nil)
            end

          %Inlet{} ->
            Inlet.compile(reference, __MODULE__)
        end
      end
    end
  end
end
