require "./spec_helper"

describe Pegmatite do
  it "tokenizes basic JSON" do
    source = <<-JSON
    {
      "hello": "world",
      "from": {
        "name": "Pegmatite",
        "version": [0, 1, 0],
        "nifty": true,
        "overcomplicated": false,
        "worse-than": null,
        "problems": []
      }
    }
    JSON
    
    Pegmatite.tokenize(Fixtures::JSON, source).should eq [
      {:object, 0, 182},
        {:pair, 4, 20},
          {:string, 5, 10}, # "hello"
          {:string, 14, 19}, # "world"
        {:pair, 24, 180},
          {:string, 25, 29}, # "from"
          {:object, 32, 180},
        {:pair, 38, 57},
          {:string, 39, 43}, # "name"
          {:string, 47, 56}, # "Pegmatite"
        {:pair, 63, 83},
          {:string, 64, 71}, # "version"
          {:array, 74, 83},
            {:number, 75, 76}, # 0
            {:number, 78, 79}, # 1
            {:number, 81, 82}, # 0
        {:pair, 89, 102},
          {:string, 90, 95}, # "nifty"
          {:true, 98, 102}, # true
        {:pair, 108, 132},
          {:string, 109, 124}, # "overcomplicated"
          {:false, 127, 132}, # false
        {:pair, 138, 156},
          {:string, 139, 149}, # "worse-than"
          {:null, 152, 156}, # null
        {:pair, 162, 176},
          {:string, 163, 171}, # "problems"
          {:array, 174, 176}, # []
    ]
  end
end
