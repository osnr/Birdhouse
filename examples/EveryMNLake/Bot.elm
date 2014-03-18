module Bot where

import Http
import Json
import JavaScript.Experimental as JS

import PureRandom
import Utils as U

import Birdhouse as BH

-- port updates : Signal (BH.StatusUpdate a)
port updates : Signal (Maybe { lat : Float, lon : Float, display_coordinates : Bool, status : String })
port updates = tweets

lakesJsonSigResp : Signal (Http.Response String)
lakesJsonSigResp = Http.sendGet . constant <| "lakes.json"

type Loc = { lat : Float, lon : Float }
type Lake = { name : String, loc : Loc }

toLakes : Json.JsonValue -> [Lake]
toLakes v = Json.toJSObject v |> JS.toRecord

toGeoUpdate : Lake -> BH.GeoUpdate (BH.StatusUpdate {})
toGeoUpdate { name, loc } = {
  status = "Lake " ++ name,
  lat = loc.lat,
  lon = loc.lon,
  display_coordinates = True }

seed : PureRandom.Gen
seed = PureRandom.mkGen 1

pos : Int
pos = 0

tweets : Signal (Maybe (BH.GeoUpdate (BH.StatusUpdate {})))
tweets = lakesJsonSigResp
       |> lift U.respToMaybe
       |> lift (U.concatMap Json.fromString)
       |> lift (U.map toLakes)
       |> lift (U.map <| map toGeoUpdate . drop pos . fst . PureRandom.shuffle seed)
       |> U.extract []
       |> U.spool (every <| 10 * second)

previews : Signal Element
previews = (\tweet -> case tweet of
                        Just t -> BH.preview t
                        Nothing -> empty) <~ tweets

consPreview : Element -> ([Element], Int) -> ([Element], Int)
consPreview p (ps, n) =
  let counter = if n == -1
                  then empty
                  else container 50 60 middle <| asText n
  in ((p `beside` counter) :: ps, n + 1)

main = flow up . fst <~ foldp consPreview ([], -1) previews
