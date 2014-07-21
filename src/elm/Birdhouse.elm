module Birdhouse where

import Dict
import Utils as U

import Text

-- things we get from other feeds
type ScreenName = String

type Id = Int
type IdStr = String

type Date = String

type Tweet = {
  created_at : String,

  entities : Entities,

  favorite_count : Int,

  id : Id,
  id_str : IdStr,

  retweet_count : Int,

  source : String,

  text : String,

  truncated : Bool,

  user : User
}

type Entities = {
  urls : [Url],
  user_mentions : [UserMention],
  hashtags : [Hashtag],
  symbols : [Symbol]
}
type Indices = (Int, Int)

type Url = {
  url : String,
  display_url : String,
  expanded_url : String,

  indices : Indices
}

type UserMention = {
  id : Id,
  id_str : IdStr,

  screen_name : String,
  name : String,

  indices: Indices
}

type Hashtag = {
  text : String,

  indices : Indices
}

type Symbol = {
  text : String,

  indices : Indices
}

type User = {
  name : String
}

-- things we send out
type StatusUpdate a = { a |
  status : String
}

type ReplyUpdate a = { a |
  in_reply_to_status_id : Id
}

type GeoUpdate a = { a |
  lat : Float,
  long : Float,

  display_coordinates : Bool
}

type PlaceUpdate a = { a |
  place_id : String
}

update : String -> StatusUpdate {}
update text = { status = text }

fromUser : Signal (Maybe (ScreenName, Tweet)) -> ScreenName -> Signal (Maybe Tweet)
fromUser tweets sn =
  let isFrom mSnTweet = case mSnTweet of
                          Just (sn, _) -> True
                          otherwise -> False
  in U.map snd <~ keepIf isFrom Nothing tweets

newFromUser : Signal (Maybe (ScreenName, Tweet)) -> ScreenName -> Signal (Maybe Tweet)
newFromUser tweets sn =
  let sameAsPrev mTweet (_, mTweet') =
        ( case (mTweet, mTweet') of
            (Just t, Just t') -> t.id == t'.id
            otherwise -> False
        , mTweet )
  in lift snd <| dropIf fst (False, Nothing) <| foldp sameAsPrev (False, Nothing) <| fromUser tweets sn

toUpdate : Tweet -> StatusUpdate {}
toUpdate { text } = update text

toUpdates : Signal (Maybe Tweet) -> Signal (Maybe (StatusUpdate {}))
toUpdates = lift (U.map toUpdate)

filter : (String -> Bool) -> Signal (Maybe (StatusUpdate {})) -> Signal (Maybe (StatusUpdate {}))
filter f ss = keepIf (\ms -> maybe False (f . .status) ms) Nothing ss

map : (String -> String) -> Signal (Maybe (StatusUpdate {})) -> Signal (Maybe (StatusUpdate {}))
map f ss = U.map (\s -> { s | status <- f s.status }) <~ ss

preview : StatusUpdate a -> Element
preview { status } = container 500 60 middle
          <| color lightGray <| container 500 50 middle <| Text.centered
               <| typeface ["helvetica", "arial", "sans-serif"]
               <| toText status

previewSignal : (a -> Element) -> Signal a -> Signal Element
previewSignal p s = flow down <~ foldp (::) [] (p <~ s)

previewM : Maybe (StatusUpdate a) -> Element
previewM sm = case sm of
                Just s -> preview s
                Nothing -> empty

previewStream : Signal (StatusUpdate a) -> Signal Element
previewStream = previewSignal preview

previewStreamM : Signal (Maybe (StatusUpdate a)) -> Signal Element
previewStreamM = previewSignal previewM
