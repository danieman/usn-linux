#!/bin/bash

# random: et spill som lar brukeren gjette et hemmelig tall

start_game () {

    vunnet=false
    hemmelig_tall=$(( 1 + RANDOM % 100 ))
    echo $hemmelig_tall

    while true; do
        echo
        read -p "Gjett det hemmelige tallet (1-100): " gjett
        if [[ ! $gjett =~ [[:digit:]] ]]; then
            echo "Du må skrive inn et tall mellom 1 og 100. Prøv igjen."
        elif [[ $gjett == 0 ]]; then
            break
        elif [[ $gjett -ge 1 && $gjett -le 100 ]]; then
            if [[ $gjett == $hemmelig_tall ]]; then
                echo "$gjett er riktig!"
                vunnet=true
                break
            elif [[ $gjett -lt $hemmelig_tall ]]; then
                echo "$gjett er mindre enn det hemmelige tallet"
                continue
            else
                echo "$gjett er større enn det hemmelige tallet"
                continue
            fi
        else
            echo "Tallet må være mellom 1 og 100. Prøv igjen."
        fi
    done
    game_over
}

game_over () {
    while true; do
        if $vunnet; then
            read -p "Vil du spille en gang til? " svar
            if [[ $svar =~ ^[jJ][aA]*$ ]]; then
                break
            elif [[ $svar =~ ^[nN](ei|EI)?$ ]]; then
                quit
            else
                echo
                echo "Svar ordentlig!"
            fi
        else
            quit
        fi
    done
    start_game
}

quit () {
    echo -n "Du valgte å avslutte. "
    if ! $vunnet; then
        echo -n "Det hemmelige tallet var ${hemmelig_tall}. "
    fi
    echo "Takk for nå!"
    exit
}

start_game
