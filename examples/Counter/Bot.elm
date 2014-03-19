module Bot where

import Birdhouse as BH

port updates : Signal { status : String } -- Signal (BH.StatusUpdate {})
port updates = BH.update . show <~ count (every (10 * second))

main = BH.previewStream updates
