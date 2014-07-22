module Bot where

import Utils as U
import String
import Maybe
import Birdhouse as BH

port getTweetsFrom : Signal [BH.ScreenName]
port getTweetsFrom = sampleOn (every minute) <| constant ["CounterElm", "CounterTimesTwo"]

port tweets : Signal (Maybe (BH.ScreenName, BH.Tweet))

counter : Signal (Maybe BH.Tweet)
counter = tweets `BH.newFromUser` "CounterElm"

counterTimesTwo : Signal (Maybe BH.Tweet)
counterTimesTwo = tweets `BH.newFromUser` "CounterTimesTwo"

port updates : Signal (Maybe { status : String })
port updates = (\mc mctt ->
                  case (mc, mctt) of
                    (Just c, Just ct) -> Just { status = "(" ++ c.status ++ ", " ++ ct.status ++ ")" }
                    otherwise -> Nothing)
               <~ BH.toUpdates counter ~ BH.toUpdates counterTimesTwo 

main = BH.previewStreamM updates
