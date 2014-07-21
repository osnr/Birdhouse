module Bot where

import Http
import Json
import Dict

import PureRandom
import Maybe
import Utils as U

import Birdhouse as BH

lakesJsonSigResp : Signal (Http.Response String)
lakesJsonSigResp = Http.sendGet . constant <| "lakes.json"

type Loc = { lat : Float, lon : Float }
type Lake = { name : String, loc : Loc }

toLoc : Json.Value -> Maybe Loc
toLoc v =
  case v of
    Json.Object d ->
      case (Dict.get "lat" d, Dict.get "lon" d) of
        (Just (Json.Number lat), Just (Json.Number lon)) -> Just { lat = lat, lon = lon }
        otherwise -> Nothing
    otherwise -> Nothing

toLake : Json.Value -> Maybe Lake
toLake v =
  case v of
    Json.Object d ->
      case (Dict.get "name" d, U.concatMap toLoc (Dict.get "loc" d)) of
        (Just (Json.String name), Just loc) -> Just { name = name, loc = loc }
        otherwise -> Nothing
    otherwise -> Nothing

toLakes : Json.Value -> [Lake]
toLakes v =
  case v of
    Json.Array ls -> Maybe.justs <| map toLake ls
    otherwise -> []

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

-- port updates : Signal (Maybe (BH.GeoUpdate (BH.StatusUpdate {})))
port updates : Signal (Maybe { lat : Float, lon : Float, display_coordinates : Bool, status : String })
port updates = lakesJsonSigResp
       |> lift U.respToMaybe
       |> lift (U.concatMap Json.fromString)
       |> lift (U.map toLakes)
       |> lift (U.map <| map toGeoUpdate . drop pos . fst . PureRandom.shuffle seed)
       |> U.extract []
       |> U.spool (every <| second)

previews : Signal Element
previews = (\update -> case update of
                         Just t -> BH.preview t
                         Nothing -> empty) <~ updates

consPreview : Element -> ([Element], Int) -> ([Element], Int)
consPreview p (ps, n) =
  let counter = if n == -1
                  then empty
                  else container 50 60 middle <| asText n
  in ((p `beside` counter) :: ps, n + 1)

main = flow down . fst <~ foldp consPreview ([], -1) previews
