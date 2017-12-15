# GenStageExample

Demo to demonstrate how buffering the pending demand from consumers and fullfilling it when events are available works.

## Running

```sh
mix deps.get
mix compile
mix run --no-halt push_demand.exs
```
