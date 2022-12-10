identification division.
program-id. rps.

environment division.
    input-output section.
        file-control.
        select tournament assign to 'input'
        organization is line sequential.

data division.
    file section.
    fd tournament.
    01 tournament-file.
        05 oppo-play pic a(1).
        05 separator pic a(1).
        05 self-play pic a(1).

    working-storage section.
    01 ws-tournament.
        05 ws-oppo-play pic a(1).
        05 ws-separator pic a(1).
        05 ws-self-play pic a(1).
    01 ws-eof pic a(1).
    01 ws-total-score pic 9999999.

procedure division.
    open input tournament.
        perform until ws-eof = 'Y'
            read tournament into ws-tournament
                at end move 'Y' to ws-eof
                not at end perform calculate-round-score
            end-read
        end-perform.
    close tournament.
    display ws-total-score.
goback.

calculate-round-score.
    *> use the same symbols for our own plays as for our opponent plays.
    *> also calculate our points for picking a shape.
    evaluate ws-self-play
        when = 'X' *> rock
            move 'A' to ws-self-play
            add 1 to ws-total-score
        when = 'Y' *> paper
            move 'B' to ws-self-play
            add 2 to ws-total-score
        when = 'Z' *> scissors
            move 'C' to ws-self-play
            add 3 to ws-total-score
    end-evaluate

    if ws-self-play is equal to ws-oppo-play then
        *> draw
        add 3 to ws-total-score
    else
        evaluate ws-self-play also ws-oppo-play
            when = 'B' also = 'A'
            when = 'C' also = 'B'
            when = 'A' also = 'C'
                *> we won! :)
                add 6 to ws-total-score
        end-evaluate
    end-if
.

end program rps.
