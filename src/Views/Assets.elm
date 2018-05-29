module Views.Assets exposing (AssetPath(..), assets)


type AssetPath
    = AssetPath String


path : AssetPath -> String
path (AssetPath str) =
    str


assets : { logo : String }
assets =
    { logo = path (AssetPath "./logo.png")
    }
