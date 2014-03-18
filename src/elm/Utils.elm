module Utils where

import Http

respToMaybe : Http.Response a -> Maybe a
respToMaybe resp = case resp of
                     Http.Success x -> Just x
                     otherwise -> Nothing

concatMap : (a -> Maybe b) -> Maybe a -> Maybe b
concatMap f m = case m of
                  Just x -> f x
                  Nothing -> Nothing

map : (a -> b) -> Maybe a -> Maybe b
map f = concatMap (Just . f)

extract : a -> Signal (Maybe a) -> Signal a
extract default sig = (\(Just x) -> x) <~ dropIf isNothing (Just default) sig

spool : Signal a -> Signal [b] -> Signal (Maybe b)
spool pace sig = 
  let tick : (a, [b]) -> (Maybe b, [b]) -> (Maybe b, [b])
      tick (_, ys) (_, xs) =
        case xs of
          x :: xs' -> (Just x, xs')
          [] -> (Nothing, ys)
  in fst <~ foldp tick (Nothing, []) ((,) <~ pace ~ sig)
