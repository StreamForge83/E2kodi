#!/bin/bash

OK_COUNT=0
ERR_COUNT=0
TOTAL=0

# ====== LISTA URL ======
URLS=(
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/Player/referencje.info"
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/PolsatBox/referencje.info"
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/TVP_VOD/referencje.info"
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/canalplus/referencje.info"
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/skylink/referencje.info"
"https://raw.githubusercontent.com/pololoko111/E2kodi/main/referencje/Megogo/referencje.info"
)

DESTS=(
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.playermb/referencje.info"
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.polsatbox_go_atv/referencje.info"
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.megogo_atv/referencje.info"
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.TVP_VOD/referencje.info"
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.canalplus/referencje.info"
"/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.directone/referencje.info"
)

TOTAL_ITEMS=${#URLS[@]}

# ====== FUNKCJA PASKA ======
draw_progress() {
    local current=$1
    local total=$2
    local percent=$(( current * 100 / total ))
    local done=$(( percent / 5 ))
    local left=$(( 20 - done ))

    printf "\r["
    printf "%0.s#" $(seq 1 $done)
    printf "%0.s-" $(seq 1 $left)
    printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
}

echo
echo "=========================================================="
echo "   START AKTUALIZACJI PLIKÓW referencje.info"
echo "=========================================================="
echo

for i in "${!URLS[@]}"; do
    TOTAL=$((TOTAL+1))

    URL="${URLS[$i]}"
    DEST="${DESTS[$i]}"

    echo
    echo "[INFO] Pobieranie:"
    echo "       $URL"
    echo "       -> $DEST"

    mkdir -p "$(dirname "$DEST")"
    curl -s -o "$DEST" "$URL"

    if [ $? -eq 0 ]; then
        echo "[OK] Plik zaktualizowany"
        OK_COUNT=$((OK_COUNT+1))
    else
        echo "[FAIL] Błąd pobierania"
        ERR_COUNT=$((ERR_COUNT+1))
    fi

    draw_progress $((i+1)) $TOTAL_ITEMS
    echo
    echo "----------------------------------------------------------"
done

echo
echo "====================== PODSUMOWANIE ======================"
echo "Wszystkie pliki : $TOTAL_ITEMS"
echo "Udane           : $OK_COUNT"
echo "Błędy           : $ERR_COUNT"
echo "=========================================================="
echo

if [ $ERR_COUNT -eq 0 ]; then
    echo "AKTUALIZACJA ZAKOŃCZONA SUKCESEM"
else
    echo "AKTUALIZACJA ZAKOŃCZONA Z BŁĘDAMI"
fi

echo
