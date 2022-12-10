module Shared exposing (..)


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
