main :: IO ()
main = do
    contents <- readFile "input"
    writeFile "a_output" $ topElfCalories contents

topElfCalories :: String -> String
topElfCalories contents =
    show
        $ (\(_, a, _) -> maximum a)
        $ doSum (0, [], lines contents)

doSum :: (Int, [Int], [String]) -> (Int, [Int], [String])
doSum (c, s, "":xs) = doSum (0, c : s, xs)
doSum (c, s, x:xs) = doSum (c + (read x :: Int), s, xs)
doSum (c, s, []) = (c , s, [])
