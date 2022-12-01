import Data.List
import Data.Ord

main :: IO ()
main = do
    contents <- readFile "input"
    writeFile "b_output" $ topThreeElfCalorieSum contents

topThreeElfCalorieSum :: String -> String
topThreeElfCalorieSum contents =
    show
        $ (\(_, a, _) -> sum . take 3 $ sortOn Data.Ord.Down a)
        $ doSum (0, [], lines contents)

doSum :: (Int, [Int], [String]) -> (Int, [Int], [String])
doSum (c, s, "":xs) = doSum (0, c : s, xs)
doSum (c, s, x:xs) = doSum (c + (read x :: Int), s, xs)
doSum (c, s, []) = (c , s, [])
