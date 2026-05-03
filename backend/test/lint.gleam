import gleam/dict
import glinter
import rules/depends_only_on
import source_map

type Packages {
  StdLib
  OpaquePackages
  DriverPackages
  InfraPackages
}

type Layer {
  Common
  Domain
  Application
  Driver
  Infrastructure
  Composition
}

type Category {
  Layer(Layer)
  Packages(Packages)
}

pub fn main() {
  let allowed_imports =
    dict.from_list([
      #(Layer(Common), [
        Layer(Common),
        Packages(StdLib),
        Packages(OpaquePackages),
      ]),
      #(Layer(Domain), [Layer(Common), Layer(Domain), Packages(StdLib)]),
      #(Layer(Application), [
        Layer(Common),
        Layer(Domain),
        Layer(Application),
        Packages(StdLib),
      ]),
      #(Layer(Driver), [
        Layer(Common),
        Layer(Domain),
        Layer(Application),
        Layer(Driver),
        Layer(Composition),
        Packages(StdLib),
        Packages(DriverPackages),
      ]),
      #(Layer(Infrastructure), [
        Layer(Common),
        Layer(Domain),
        Layer(Application),
        Layer(Driver),
        Layer(Infrastructure),
        Packages(StdLib),
        Packages(InfraPackages),
      ]),
    ])

  let path_layer_pairs = [
    #(Layer(Common), "common"),
    #(Layer(Domain), "domain"),
    #(Layer(Application), "application"),
    #(Layer(Driver), "driver"),
    #(Layer(Infrastructure), "infrastructure"),
    #(Layer(Composition), "composition"),
    #(Packages(StdLib), "gleam"),
    #(Packages(InfraPackages), "sqlight"),
    #(Packages(DriverPackages), "wisp"),
    #(Packages(OpaquePackages), "youid"),
  ]

  let source_map = source_map.build_source_map("./src")
  glinter.run(extra_rules: [
    depends_only_on.rule(
      depends_only_on.Config(allowed_imports:, path_layer_pairs:),
      source_map,
    ),
  ])
}
