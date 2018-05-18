# YAWC

Yet Another Wrapper Compiler.

Thanks to this beatiful library, defining an unnecessary wrapper around an Erlang library in Elixir
is just a matter of a single line of code!

```elixir
defmodule UselessWrapper do
  import YAWC

  wrap :awesome_library
end
```

Amazing! But do you want to know the real secret sauce? You can define wrappers around Elixir
modules, too!

```elixir
defmodule UselessWrapper do
  import YAWC

  wrap AwesomeLibrary
end
```

## WARNING

Please don't use this library to create wrapper libraries. To be honest, you'd be better off not
using it at all.

## License

Licensed under [WTFPL](www.wtfpl.net). See `LICENSE` file for more information.
