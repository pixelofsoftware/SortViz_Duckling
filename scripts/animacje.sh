#!/usr/bin/env bash
# Buduje program i zapisuje animacje HTML wszystkich sześciu algorytmów do build/animacje/
# (te same losowe dane dla każdego) razem ze stroną index.html, która je zbiera.
#
#   scripts/animacje.sh            # n = 40, ziarno 2026
#   scripts/animacje.sh 60 7       # własne n (1-100) i ziarno
set -euo pipefail
cd "$(dirname "$0")/.."
n="${1:-40}"
ziarno="${2:-2026}"

name="$(sed -n 's/^[[:space:]]*name:[[:space:]]*//p' quackconfig.yaml | head -n 1 | tr -d "\"'")"
duck build > /dev/null
exe=".duck_build/dev/$name"
out="build/animacje"
mkdir -p "$out"

nazwy=("" "babelkowe" "wstawianie" "wybieranie" "scalanie" "szybkie" "kopcowanie")
opisy=("" "b&#261;belkowe" "przez wstawianie" "przez wybieranie" "przez scalanie" "szybkie" "przez kopcowanie")
{
    echo "<!DOCTYPE html><html lang='pl'><head><meta charset='utf-8'><title>SortViz</title>"
    echo "<style>body{font-family:system-ui,sans-serif;background:#0f172a;color:#e2e8f0;padding:32px}a{color:#60a5fa;font-size:18px}li{margin:10px 0}pre{white-space:pre-wrap}</style></head><body>"
    echo "<h1>SortViz: animacje sortowania</h1><p>n = $n, losowe liczby 1&ndash;99, ziarno $ziarno.</p><ul>"
    for nr in 1 2 3 4 5 6; do
        echo "$nr 2 2 $n $ziarno" | "$exe" > "$out/${nazwy[$nr]}.html"
        echo "<li><a href='${nazwy[$nr]}.html'>Sortowanie ${opisy[$nr]}</a></li>"
    done
    echo "</ul><pre>"
    echo "0 3 2 $n $ziarno" | "$exe"
    echo "</pre></body></html>"
} > "$out/index.html"
echo "Animacje w $out/ (otwórz $out/index.html w przeglądarce)"
