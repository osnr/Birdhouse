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

port updates : Signal (Maybe { status : String })
port updates = BH.map (\s -> show <| maybe 0 (\x -> x * 2) <| String.toInt s)
               <| BH.toUpdates counter

main = BH.previewStreamM updates
