# Adding Plumbery to an application

To add Plumbery to an application, add `:plumbery` as a dependency:

```elixir
defp deps do
  [
    {:plumbery, "~> 0.1"}
  ]
end
```

If you want your code using the Plumbery DSL to be formatted as examples in this documentation, add `:plumbery` to `import_deps` in `.formatter.exs`:

```elixir
[
  import_deps: [:plumbery],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"]
]
```
