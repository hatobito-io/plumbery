
# Plumbery

<!--
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hexdocs badge](https://img.shields.io/badge/docs-hexdocs-purple)](https://hexdocs.pm/plumbery)
[![Hex version badge](https://img.shields.io/hexpm/v/plumbery.svg)](https://hex.pm/packages/plumbery)
-->

Plumbery is a framework for building pipelines in a declarative way. Pipeline
is just a function that accepts a struct and returns the same kind of struct.
This pattern is used by frameworks such as Plug and Ecto, and Plumbery may look
familiar if you used those frameworks, but it provides a generic API instead of
more specialized one. This pattern is often referred as Railway Oriented
Programming.


Plumbery provides tools for pipeline composition. A pipeline is composed from
functions (including other pipelines). When the pipeline function is called,
the functions inside the pipeline are called sequentially, stopping if one of
the functions returns an error or explicitly halts the pipeline.

All functions in a pipline accept exactly one argument called a request.
Request is a struct that must have some predefined fields used for pipeline
management, but can contain additional fields. Utilities are provided that can
generate pipeline entry functions that accept arbitrary arguments and convert
them into the struct expected by the pipeline.

```elixir
defmodule Example do
  use Plumbery
  import Plumbery.Request

  defp validate(req = %Plumbery.Request{}) do
    case req.command do
      %{number: n, mul: m} when is_integer(n) and n > 0 and is_integer(m) -> req
      _ -> error(req, :invalid_number)
    end
  end

  defp calculate(req = %Plumbery.Request{command: %{number: n, mul: m}}) do
    success(req, n * m)
  end

  pipeline :mult do
    private true
    unwrap true

    pipe :validate
    pipe :calculate
  
    inlet multiply(number, mul \\ 42), use_context: false
  end

end

{:error, :invalid_number} = Example.multiply(0)
{:ok, 126} = Example.multiply(3)
{:ok, 56} = Example.multiply(7, 8)
```
