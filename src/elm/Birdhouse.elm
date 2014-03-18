module Birdhouse where

import Date
import Dict

type Id = Int
type IdStr = String

type Tweet a = { a |
  created_at : Date.Date,

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
  media : [Media],
  urls : [Url],
  user_mentions : [UserMention],
  hashtags : [Hashtag],
  symbols : [Symbol]
}
type Indices = (Int, Int)

type Media = {
  id : Id,
  id_str : IdStr,

  media_url : String,
  media_url_https : String,

  url : String,
  display_url : String,
  expanded_url : String,

  sizes : Sizes,

  type_ : String,

  indices : Indices
}
type Sizes = {
  foo : Int
}

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
  bar : Int
}

-- extensions of Tweet
type Reply a = { a |
  in_reply_to_screen_name : String,
  in_reply_to_status_id : Id,
  in_reply_to_status_id_str : IdStr,
  in_reply_to_user_id : Id,
  in_reply_to_user_id_str : IdStr
}

type Retweet a = { a |
  retweeted_status : Tweet a
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
  lon : Float,

  display_coordinates : Bool
}

type PlaceUpdate a = { a |
  place_id : String
}

tweet : String -> StatusUpdate {}
tweet text = { status = text }

display : Tweet a -> Element
display { text } = plainText text

preview : StatusUpdate a -> Element
preview { status } = container 500 60 middle
          <| color lightGray <| container 500 50 middle <| text
               <| typeface "helvetica, arial, sans-serif"
               <| toText status

previewStream : Signal (StatusUpdate a) -> Signal Element
previewStream tweets = flow up <~ foldp (::) [] (preview <~ tweets)
