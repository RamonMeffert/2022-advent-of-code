module A exposing (..)

import Input exposing (inputA)
import String


run =
    let
        lines =
            String.lines inputA
    in
    List.foldr getPriorities [] lines
        |> List.sum


getPriorities : String -> List Int -> List Int
getPriorities line prios =
    let
        len =
            String.length line

        strList =
            String.toList line

        firstHalf =
            strList |> List.take (len // 2)

        secndHalf =
            strList |> List.drop (len // 2)

        prio =
            List.filter (\x -> List.member x firstHalf) secndHalf
                |> List.map charToPriority
                |> List.head
                |> Maybe.withDefault 0
    in
    prio :: prios


charToPriority : Char -> Int
charToPriority c =
    let
        code =
            Char.toCode c
    in
    if code >= 65 && code <= 90 then
        code - 64 + 26

    else
        code - 96
