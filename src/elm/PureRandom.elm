module PureRandom where

import Dict

data Gen = Gen Int Int

mkGen : Int -> Gen
mkGen s =
  if | s < 0     -> mkGen (-s)
     | otherwise -> let q = s `div` 2147483562
                        s1 = s `mod` 2147483562
                        s2 = q `mod` 2147483398
                    in Gen (s1+1) (s2+1)

next : Gen -> (Int, Gen)
next (Gen s1 s2) =
  let z'   = if z < 1 then z + 2147483562 else z
      z    = s1'' - s2''

      k    = s1 `div` 53668
      s1'  = 40014 * (s1 - k * 53668) - k * 12211
      s1'' = if s1' < 0 then s1' + 2147483563 else s1'

      k'   = s2 `div` 52774
      s2'  = 40692 * (s2 - k' * 52774) - k' * 3791
      s2'' = if s2' < 0 then s2' + 2147483399 else s2'

  in (z', Gen s1'' s2'')

randomInt : (Int, Int) -> Gen -> (Int, Gen)
randomInt (l, h) rng =
  if | l > h     -> randomInt (h, l) rng
     | otherwise ->
       let k = h - l + 1
           b = 2147483561
           n = iLogBase b k

           f m acc g =
             case m of
               0 -> (acc, g)
               n' -> let (x, g') = next g
                     in f (n' - 1) (x + acc * b) g'
       in case (f n 1 rng) of
            (v, rng') -> (l + v `mod` k, rng')

shuffleStep : (Int, a) -> (Dict.Dict Int a, Gen) -> (Dict.Dict Int a, Gen)
shuffleStep (i, x) (m, gen) =
  let (j, gen') = randomInt (0, i) gen
      m' = Dict.insert j x <|
           if j /= i
             then Dict.insert i ((\(Just y) -> y) <| Dict.get j m) m
             else m
  in (m', gen')

shuffle : Gen -> [a] -> ([a], Gen)
shuffle gen l =
  case l of
    [] -> ([], gen)
    l  ->
      let toElems (d, y) = (Dict.values d, y)
          numerate tl = zip [1..length tl] tl
          initial x gen = (Dict.singleton 0 x, gen)
      in toElems <| foldl shuffleStep (initial (head l) gen) (numerate (tail l))

iLogBase : Int -> Int -> Int
iLogBase b i = if i < b then 1 else 1 + iLogBase b (i `div` b)
