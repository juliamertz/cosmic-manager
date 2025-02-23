{ lib, runCommandLocal }:
let
  results = lib.runTests {
    testFromRonBool = {
      expr = lib.cosmic.generators.fromRON "true";
      expected = true;
    };

    testFromRonChar = {
      expr = lib.cosmic.generators.fromRON "'a'";

      expected = {
        __type = "char";
        value = "a";
      };
    };

    testFromRonEnum = {
      expr = lib.cosmic.generators.fromRON "FooBar";
      # Simple enum variants are basically the same as raw values. So I didn't
      # bother to add a special case for them in the fromRON function.
      expected = {
        __type = "raw";
        value = "FooBar";
      };
    };

    testFromRonFloat = {
      expr = lib.cosmic.generators.fromRON "3.14";
      expected = 3.14;
    };

    testFromRonInt = {
      expr = lib.cosmic.generators.fromRON "333";
      expected = 333;
    };

    testFromRonList = {
      expr = lib.cosmic.generators.fromRON ''
        [
          "foo",
          "bar",
          "baz"
        ]
      '';

      expected = [
        "foo"
        "bar"
        "baz"
      ];
    };

    testFromRonMap = {
      expr = lib.cosmic.generators.fromRON ''
        {
          "foo": (bar: "baz")
        }
      '';

      expected = {
        __type = "map";
        value = [
          {
            key = "foo";
            value = {
              bar = "baz";
            };
          }
        ];
      };
    };

    testFromRonNamedStruct = {
      expr = lib.cosmic.generators.fromRON ''
        foo(
          bar: "baz"
        )
      '';

      expected = {
        __type = "namedStruct";
        name = "foo";
        value = {
          bar = "baz";
        };
      };
    };

    testFromRonOptional = {
      expr = lib.cosmic.generators.fromRON ''Some("foo")'';

      expected = {
        __type = "optional";
        value = "foo";
      };
    };

    testFromRonRaw = {
      expr = lib.cosmic.generators.fromRON "foo";
      expected = {
        __type = "raw";
        value = "foo";
      };
    };

    testFromRonString = {
      expr = lib.cosmic.generators.fromRON ''"foo"'';
      expected = "foo";
    };

    testFromRonStruct = {
      expr = lib.cosmic.generators.fromRON ''( a: (b: (c: "foo")))'';
      expected.a.b.c = "foo";
    };

    testFromRonTuple = {
      expr = lib.cosmic.generators.fromRON ''("foo", "bar", "baz", 3.14, 333)'';
      expected = {
        __type = "tuple";
        value = [
          "foo"
          "bar"
          "baz"
          3.14
          333
        ];
      };
    };

    testToRonTupleEnum = {
      expr = lib.cosmic.generators.fromRON ''Path("/some/path", "/another/path")'';
      expected = {
        __type = "enum";
        variant = "Path";
        value = [
          "/some/path"
          "/another/path"
        ];
      };
    };
  };
in
if results == [ ] then
  runCommandLocal "to-ron-success" { } "touch $out"
else
  runCommandLocal "to-ron-failure"
    {
      results = builtins.concatStringsSep "\n" (
        map (result: ''
          ${result.name}:
            expected: ${lib.generators.toPretty { } result.expected}
            actual: ${lib.generators.toPretty { } result.result}
        '') results
      );
    }
    ''
      echo -e "Tests failed:\\n\\n$results" >&2
      exit 1
    ''
