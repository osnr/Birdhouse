module Bot where

import Birdhouse as BH

port tweets : Signal (Maybe (BH.ScreenName, BH.Tweet))

port updates : Signal { status : String } -- (BH.StatusUpdate {})
port updates = BH.update . show <~ count (every (10 * second))

main = BH.previewStream updates
