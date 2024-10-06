defmodule Plumbery.Dsl do
  @moduledoc false
  @pipe %Spark.Dsl.Entity{
    describe: """
    Adds a pipe to pipeline.
    """,
    name: :pipe,
    target: Plumbery.Pipe,
    args: [:function],
    transform: {Plumbery.Pipe.Validator, :validate, []},
    schema: [
      function: [
        type: {
          :or,
          [
            :atom,
            {:tuple, [:module, :atom]}
          ]
        },
        doc:
          "Function to call. Can be either local function name specified as atom, or remote function specified as {Module, :function} tuple. Local functions can be private"
      ]
    ]
  }

  @embedded_inlet %Spark.Dsl.Entity{
    name: :inlet,
    target: Plumbery.Inlet,
    transform: {Plumbery.Inlet.Validator, :validate, []},
    args: [:signature],
    schema: [
      signature: [
        type: :quoted,
        required: true
      ],
      request: [
        type: :module
      ],
      command: [
        type: :module
      ],
      use_context: [
        type: :boolean
      ]
    ]
  }

  @escape_on_error %Spark.Dsl.Entity{
    name: :escape_on_error,
    target: Plumbery.EscapeOnError,
    args: [:escape],
    schema: [
      escape: [
        type: :boolean
      ]
    ]
  }

  @pipeline %Spark.Dsl.Entity{
    name: :pipeline,
    entities: [pipes: [@pipe, @escape_on_error], inlets: [@embedded_inlet]],
    target: Plumbery.Pipeline,
    transform: {Plumbery.Pipeline.Validator, :validate, []},
    args: [:name],
    schema: [
      name: [
        type: :atom,
        required: true,
        doc: "The name of the pipeline"
      ],
      doc: [
        type: :string,
        doc: "Documentation for generated function"
      ],
      unwrap: [
        type: :boolean,
        default: false,
        doc:
          "When true, the pipeline will unwrap the result before returning. Makes sense only for pipelines that are not meant to be used in other pipelines"
      ],
      private: [
        type: :boolean,
        default: false,
        doc: "When true, the generated pipeline function is private"
      ]
    ]
  }

  @inlet %Spark.Dsl.Entity{
    name: :inlet,
    target: Plumbery.Inlet,
    transform: {Plumbery.Inlet.Validator, :validate, []},
    args: [:signature],
    schema: [
      signature: [
        type: :quoted,
        required: true
      ],
      request: [
        type: :module
      ],
      command: [
        type: :module
      ],
      use_context: [
        type: :boolean
      ],
      pipeline: [
        type: {:or, [:module, {:tuple, [:module, :atom]}]},
        required: true
      ]
    ]
  }

  @dsl %Spark.Dsl.Section{
    name: :plumbery,
    top_level?: true,
    entities: [@pipeline, @inlet]
  }

  use Spark.Dsl.Extension, sections: [@dsl]
end
