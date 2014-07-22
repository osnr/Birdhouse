module Bot where

import Utils as U
import Maybe
import Birdhouse as BH

port getTweetsFrom : Signal [BH.ScreenName]
port getTweetsFrom = sampleOn (every (30 * second)) (constant ["CounterElm"])

port tweets : Signal (Maybe (BH.ScreenName, BH.Tweet))

everyMNLake : Signal (Maybe BH.Tweet)
everyMNLake = tweets `BH.newFromUser` "CounterElm"

port updates : Signal (Maybe { status : String })
port updates = BH.map (\x -> "ghost " ++ x) (BH.toUpdates everyMNLake)

main = BH.previewStreamM updates
