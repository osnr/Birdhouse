module Bot where

import Birdhouse as BH

port updates : Signal { status : String }
port updates = tweets

tweets : Signal (BH.StatusUpdate {})
tweets = BH.tweet . show <~ count (every (10 * second))

main = BH.previewStream tweets
