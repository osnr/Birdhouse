module Bot where

import Utils as U
import String
import Maybe
import Birdhouse as BH

port getTweetsFrom : Signal [BH.ScreenName]
port getTweetsFrom = sampleOn (every (2 * minute)) <| constant ["CounterElm"]

port tweets : Signal (Maybe (BH.ScreenName, BH.Tweet))

counter : Signal (Maybe BH.Tweet)
counter = tweets `BH.newFromUser` "CounterElm"

port updates : Signal { status : String }
port updates = lift (BH.update . show)
               <| BH.fold (\s acc -> maybe 0 (\x -> acc + x) <| String.toInt s) 0
               <| BH.toUpdates counter

main = BH.previewStream updates
