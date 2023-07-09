#!/bin/zsh
# Created 07/09/23; NRJA

##############################################
# Quick 'n' dirty script to average individual
# IMDB episode ratings into season-wide avgs
# for a desired TV series (SHOW)
# Populate SHOW="" value for ttXXXXXXX from
# IMDB URL for target series to get aggregated
# score averaged season-by-season
##############################################v

SHOW="tt3032476" # BCS

SHOW_NAME=$(curl -s -L "https://www.imdb.com/title/${SHOW}/episodes" | grep '\<title\>.*(TV Series' | /usr/bin/sed -n -e 's/^.*content="//p' | cut -d '"' -f1)

SEASONS=$(curl -s -L "https://www.imdb.com/title/${SHOW}/episodes" | grep -A300 'Season:' | grep 'option selected="selected" value=' | cut -d '"' -f4)

echo "Averaging IMDB ratings for all ${SEASONS} seasons of ${SHOW_NAME}...\n"

for i in {1..${SEASONS}}; do
    SEASON=${i}
    SEASON_RATINGS=$(curl -s -L "https://www.imdb.com/title/${SHOW}/episodes?season=${SEASON}" | grep '<span class="ipl-rating-star__rating">' | grep -o '\d.\d')
    EPISODE_COUNT=$(wc -l <<< "${SEASON_RATINGS}")
    COMBINED_AVERAGE=$(xargs <<< "${SEASON_RATINGS}" | sed -e 's/ /+/g' | bc)
    AVERAGE_SCORE=$((${COMBINED_AVERAGE} / ${EPISODE_COUNT}))
    echo "Season ${i}: ${AVERAGE_SCORE}"
done
