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
        05 ws-strategy pic a(1).
    01 ws-eof pic a(1).
    01 ws-total-score pic 9999999.
    01 ws-play pic a(1).

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
    perform find-move.
    perform calculate-outcome-score.
.

find-move.
    evaluate ws-strategy also ws-oppo-play
        *> loss
        when = 'X' also = 'A'
            *> we play scissors against rock
            move 'C' to ws-play
        when = 'X' also = 'B'
            *> we play rock against paper
            move 'A' to ws-play
        when = 'X' also = 'C'
            *> we play paper against scissors
            move 'B' to ws-play

        *> draw
        when = 'Y' also any
            move ws-oppo-play to ws-play

        *> win
        when = 'Z' also = 'A'
            *> we play paper against rock
            move 'B' to ws-play
        when = 'Z' also = 'B'
            *> we play scissors against paper
            move 'C' to ws-play
        when = 'Z' also = 'C'
            *> we play rock against scissors
            move 'A' to ws-play
    end-evaluate
.

calculate-outcome-score.
    evaluate ws-strategy
        when = 'Y'
            add 3 to ws-total-score
        when = 'Z'
            add 6 to ws-total-score
    end-evaluate

    evaluate ws-play
        when = 'A'
            add 1 to ws-total-score
        when = 'B'
            add 2 to ws-total-score
        when = 'C'
            add 3 to ws-total-score
    end-evaluate
.

end program rps.
