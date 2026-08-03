```bash
#!/bin/bash

OK_COUNT=0
ERR_COUNT=0

# ====== LISTA URL ======
URLS=(
    "https://raw.githubusercontent.com/StreamForge83/E2kodi/main/referencje/Player/referencje.info"
    "https://raw.githubusercontent.com/StreamForge83/E2kodi/main/referencje/PolsatBox/referencje.info"
    "https://raw.githubusercontent.com/StreamForge83/E2kodi/main/referencje/TVP_VOD/referencje.info"
    "https://raw.githubusercontent.com/StreamForge83/E2kodi/main/referencje/canalplus/referencje.info"
    "https://raw.githubusercontent.com/StreamForge83/E2kodi/main/referencje/skylink/referencje.info"
)

# ====== MIEJSCA DOCELOWE ======
DESTS=(
    "/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.playermb/referencje.info"
    "/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.polsatbox_go_atv/referencje.info"
    "/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.TVP_VOD/referencje.info"
    "/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.canalplus/referencje.info"
    "/usr/lib/enigma2/python/Plugins/Extensions/E2Kodi/site-packages/emukodi/Plugins/plugin.video.directone/referencje.info"
)

TOTAL_ITEMS=${#URLS[@]}
TOTAL_DESTS=${#DESTS[@]}

# ====== SPRAWDZENIE LIST ======
if [ "$TOTAL_ITEMS" -ne "$TOTAL_DESTS" ]; then
    echo
    echo "[BŁĄD] Liczba adresów URL nie zgadza się z liczbą plików docelowych."
    echo "URL  : $TOTAL_ITEMS"
    echo "DEST : $TOTAL_DESTS"
    echo
    exit 1
fi

# ====== FUNKCJA PASKA POSTĘPU ======
draw_progress() {
    local current=$1
    local total=$2
    local percent
    local done
    local left
    local j

    if [ "$total" -le 0 ]; then
        return
    fi

    percent=$((current * 100 / total))
    done=$((percent / 5))
    left=$((20 - done))

    printf "\r["

    j=0
    while [ "$j" -lt "$done" ]; do
        printf "#"
        j=$((j + 1))
    done

    j=0
    while [ "$j" -lt "$left" ]; do
        printf "-"
        j=$((j + 1))
    done

    printf "] %d%% (%d/%d)" "$percent" "$current" "$total"
}

echo
echo "=========================================================="
echo "   START AKTUALIZACJI PLIKÓW referencje.info"
echo "=========================================================="
echo

for i in "${!URLS[@]}"; do
    URL="${URLS[$i]}"
    DEST="${DESTS[$i]}"
    TMP="${DEST}.tmp"

    echo "[INFO] Pobieranie:"
    echo "       $URL"
    echo "       -> $DEST"

    if ! mkdir -p "$(dirname "$DEST")"; then
        echo "[FAIL] Nie można utworzyć katalogu docelowego"
        ERR_COUNT=$((ERR_COUNT + 1))

        draw_progress $((i + 1)) "$TOTAL_ITEMS"
        echo
        echo "----------------------------------------------------------"
        continue
    fi

    rm -f "$TMP"

    if curl -fLsS \
        --connect-timeout 15 \
        --max-time 60 \
        -o "$TMP" \
        "$URL"; then

        if [ -s "$TMP" ]; then
            if mv -f "$TMP" "$DEST"; then
                echo "[OK] Plik zaktualizowany"
                OK_COUNT=$((OK_COUNT + 1))
            else
                echo "[FAIL] Nie można zapisać pliku docelowego"
                rm -f "$TMP"
                ERR_COUNT=$((ERR_COUNT + 1))
            fi
        else
            echo "[FAIL] Pobrany plik jest pusty"
            rm -f "$TMP"
            ERR_COUNT=$((ERR_COUNT + 1))
        fi
    else
        echo "[FAIL] Błąd pobierania"
        rm -f "$TMP"
        ERR_COUNT=$((ERR_COUNT + 1))
    fi

    draw_progress $((i + 1)) "$TOTAL_ITEMS"
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

if [ "$ERR_COUNT" -eq 0 ]; then
    echo "AKTUALIZACJA ZAKOŃCZONA SUKCESEM"
    EXIT_CODE=0
else
    echo "AKTUALIZACJA ZAKOŃCZONA Z BŁĘDAMI"
    EXIT_CODE=1
fi

echo
exit "$EXIT_CODE"
```
