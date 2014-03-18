{-# LANGUAGE RecordWildCards, NamedFieldPuns, OverloadedStrings, DeriveDataTypeable, DeriveGeneric #-}

import Prelude hiding (takeWhile)

import Network.HTTP
import Network.HTTP.Conduit

import Control.Concurrent

import qualified Data.ByteString.Lazy as BL

import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Text.IO as TIO

import Data.Maybe
import Data.Dynamic
import Control.Exception hiding (try)

import Data.Attoparsec.Combinator
import Data.Attoparsec.Text

import Control.Applicative
import Control.Monad

import GHC.Generics
import Data.Aeson

import Control.Lens
import Control.Lens.Aeson

data WikiLake = WikiLake {
      wName :: String
    , wCounty :: String
    , wNearbyTown :: String
    , wSize :: String
    , wLittoralZone :: String
    , wMaxDepth :: String
    , wWaterClarity :: String } deriving (Show)

type ParseError = String
data ParseException = ParseException ParseError String deriving (Show, Typeable)
instance Exception ParseException

data Loc = Loc { lat :: Double, lon :: Double } deriving (Show, Generic)
instance ToJSON Loc

data Lake = Lake {
      name :: String
    , county :: String
    , nearbyTown :: String
    , size :: String
    , littoralZone :: String
    , maxDepth :: String
    , waterClarity :: String
    , loc :: Maybe Loc } deriving (Show, Generic)

instance ToJSON Lake

page :: Parser [Maybe [String]]
page = many1 line <* skipSpace <* endOfInput
       <?> "page"
    where line = ((pure Nothing <* (string "|-" <|> string "|}") <* takeTill isEndOfLine)
                  <|> (Just <$> row)
                  <|> (pure Nothing <* satisfy (== '\n'))
                  <|> (pure Nothing <* takeWhile1 (not . isEndOfLine)))

row :: Parser [String]
row = char '|' *> fields
      <?> "row"
    where fields = count 7 field
                   <?> "fields"
          field = skipWhile isHorizontalSpace
                  *> manyTill anyChar (skipWhile isHorizontalSpace  -- FIXME inefficient
                                       <* ((pure () <* string "||") <|> endOfLine))
                  <?> "field"

parsePage :: T.Text -> Either ParseError [WikiLake]
parsePage s = map toWLake . catMaybes <$> parseOnly page s
    where toWLake :: [String] -> WikiLake
          toWLake ( wName :
                    wCounty :
                    wNearbyTown :
                    wSize :
                    wLittoralZone :
                    wMaxDepth :
                    wWaterClarity : [] ) = WikiLake {..}

unlinkify :: String -> Either ParseError String
unlinkify = parseOnly (T.unpack <$> link) . T.pack
    where link :: Parser T.Text
          link = (string "[[" *> takeWhile (/= '|') *> char '|'
                  *> takeWhile (/= ']')
                  <* string "]]")
                 <|> takeText
                 <?> "link"

unwrapParse :: String -> Either ParseError a -> IO a
unwrapParse source = either (throwIO . ParseException source) return

toLake :: WikiLake -> IO Lake
toLake (WikiLake {..}) = do
  let unlinkifyIO source = unwrapParse source . unlinkify

  name <- unlinkifyIO ("wName = " ++ wName) wName
  county <- unlinkifyIO ("wCounty = " ++ wCounty) wCounty
  nearbyTown <- unlinkifyIO ("wNearbyTown = " ++ wNearbyTown) wNearbyTown

  loc <- geocode wName wNearbyTown

  return Lake { name
              , county
              , nearbyTown
              , size = wSize
              , littoralZone = wLittoralZone
              , maxDepth = wMaxDepth
              , waterClarity = wWaterClarity
              , loc }

geocode :: String -> String -> IO (Maybe Loc)
geocode name nearbyTown = do
  let params = [("address", "Lake " ++ name ++ ", " ++ nearbyTown ++ ", Minnesota"),
                ("sensor", "false")]
  respJson <- simpleHttp ("http://maps.googleapis.com/maps/api/geocode/json?" ++ urlEncodeVars params)

  threadDelay 500000 -- 0.5s delay to respect Google

  let loc = do bounds <- respJson ^? key "results" . nth 0 . key "geometry" . key "bounds" 

               let _lat = key "lat" . _Number
                   _lon = key "lng" . _Number
                   average x y = (x + y) / 2

               lat <- average <$> (bounds ^? key "northeast" . _lat) <*> (bounds ^? key "southwest" . _lat)
               lon <- average <$> (bounds ^? key "northeast" . _lon) <*> (bounds ^? key "southwest" . _lon)

               return Loc { lat = fromNumber lat, lon = fromNumber lon }

  return loc
      where fromNumber :: Number -> Double
            fromNumber (I i) = fromIntegral i
            fromNumber (D d) = d

main :: IO ()
main = do
  wText <- TE.decodeUtf8 . BL.toStrict <$> simpleHttp "http://en.wikipedia.org/w/index.php?title=List%20of%20lakes%20in%20Minnesota&action=raw"
  wLakes <- unwrapParse "Wikipedia raw" $ parsePage wText

  lakes <- filter (isJust . loc) <$> mapM toLake wLakes

  let json = TE.decodeUtf8 . BL.toStrict $ encode lakes
  TIO.writeFile "../lakes.json" json
