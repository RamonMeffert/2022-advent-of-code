module B exposing (..)

import Input exposing (inputA)
import Shared exposing (charToPriority)

run =
    let
        lines =
            String.lines inputA
    in
    getBackpacks lines
        |> List.map getCommonItemScore
        |> List.map List.head
        |> List.map (Maybe.withDefault '0')
        |> List.map charToPriority
        |> List.sum

firstItem =
    let
        lines =
            String.lines inputA
    in
    getBackpacks lines
        |> List.map List.length


-- Group input lines by threes
getBackpacks : List a -> List (List a)
getBackpacks lines =
    let
        collect line (backpack, backpacks) =
            if List.length backpack < 2 then
                (line :: backpack, backpacks)
            else 
                ([], (line :: backpack) :: backpacks)

    in
    List.foldr collect ([], []) lines |> Tuple.second

-- getCommonItemScore : List String -> Int
getCommonItemScore backpack =
    let
        charLists = List.map String.toList backpack
        firstList = List.head charLists |> Maybe.withDefault []
        findCommon : List Char -> List Char -> List Char
        findCommon common newList =
            List.filter (\x -> List.member x common) newList
    in
    List.foldr findCommon firstList charLists