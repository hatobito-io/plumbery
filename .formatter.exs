# Used by "mix format"
spark_locals_without_parens = [
  command: 1,
  doc: 1,
  escape_on_error: 1,
  escape_on_error: 2,
  inlet: 1,
  inlet: 2,
  pipe: 1,
  pipe: 2,
  pipeline: 1,
  pipeline: 2,
  private: 1,
  request: 1,
  unwrap: 1,
  use_context: 1
]

locals_without_parens = spark_locals_without_parens

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,examples}/**/*.{ex,exs}"],
  plugins: [Spark.Formatter],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
