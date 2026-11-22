# SortViz: wizualizacja algorytmów sortowania w Ducklingu

![Napisane w Duckling](https://img.shields.io/badge/napisane%20w-Duckling-f2c94c)
[![CI](https://github.com/pixelofsoftware/SortViz_Duckling/actions/workflows/ci.yml/badge.svg)](https://github.com/pixelofsoftware/SortViz_Duckling/actions/workflows/ci.yml)

Program w języku [Duckling](https://github.com/ducktype-org/duckling), który pokazuje, jak działa sześć
algorytmów sortowania: krok po kroku w terminalu, jako animację HTML w przeglądarce albo jako tabelę
porównującą liczbę operacji. Projekt powstał z szablonu
[duckling-template](https://github.com/pixelofsoftware/duckling-template).

> **Duckling** to nowy, statycznie typowany język programowania rozwijany przez DuckType.
> Repozytorium języka: **https://github.com/ducktype-org/duckling**
> · [dokumentacja](https://docs.duckling.pl/) · [strona](https://duckling.pl/) · [wydania](https://github.com/ducktype-org/duckling/releases)
>
> Duckling jest w fazie alfa (v0.3): składnia i biblioteki wciąż się zmieniają.

| nr | algorytm | złożoność (średnio) | co widać na animacji |
|---|---|---|---|
| 1 | bąbelkowe | O(n²) | duże wartości „wypływają” na koniec, para po parze |
| 2 | przez wstawianie | O(n²) | każdy kolejny element cofa się na swoje miejsce |
| 3 | przez wybieranie | O(n²) | dużo porównań, mało zamian: najmniejszy trafia na początek |
| 4 | przez scalanie | O(n log n) | posortowane fragmenty 1, 2, 4, 8... scalane w coraz dłuższe |
| 5 | szybkie | O(n log n) | podział względem osi (ostatni element), potem obie części osobno |
| 6 | przez kopcowanie | O(n log n) | budowa kopca, potem największy element na koniec |

## Szybki start

Potrzebny jest Duckling 0.3 (instalacja: [wydanie v0.3](https://github.com/ducktype-org/duckling/releases/tag/v0.3),
szczegóły w [szablonie](https://github.com/pixelofsoftware/duckling-template#wymagania)).

```bash
duck build
scripts/animacje.sh                 # animacje wszystkich algorytmów w build/animacje/index.html
```

Program czyta parametry ze standardowego wejścia, więc pojedyncze uruchomienia wyglądają tak:

```bash
P=.duck_build/dev/sortviz
echo "5 2 2 40 2026" | $P > szybkie.html    # animacja sortowania szybkiego, 40 losowych liczb
echo "2 1 1 6  5 2 4 6 1 3" | $P            # sortowanie przez wstawianie krok po kroku w terminalu
echo "0 3 2 1000 42" | $P                   # porównanie wszystkich algorytmów na 1000 liczbach
$P < przyklady/kopcowanie_malejace.txt > kopiec.html
```

(Program uruchamiamy bezpośrednio, a nie przez `duck run`, żeby na wyjściu był tylko jego wynik, np. czysty plik HTML.)

## Wejście

```
algorytm tryb dane n [ziarno | a1 a2 ... an]
```

Liczby całkowite rozdzielone dowolnymi białymi znakami.

| pole | wartości |
|---|---|
| `algorytm` | 1–6 jak w tabeli wyżej; 0 = wszystkie (tylko w trybie 3) |
| `tryb` | 1 = klatki w terminalu, 2 = animacja HTML na standardowe wyjście, 3 = porównanie liczby operacji |
| `dane` | 1 = podane liczby `a1..an`, 2 = losowe 1–99 z ziarnem, 3 = malejące n..1, 4 = rosnące 1..n |
| `n` | 1–100 w trybach 1 i 2, 1–5000 w trybie 3 |

Błędne parametry kończą program z kodem 1 i komunikatem `blad: ...`.

## Tryby

**Terminal (1).** Każde porównanie, zamiana i zapis to osobna klatka: tablica jako poziome słupki,
`<- ?` przy porównywanych pozycjach, `<- *` przy zmienionych. Na końcu liczniki i wynik.

```
krok 1: porownanie [0] [3]
0 | 3 ###########################              <- ?
1 | 1 #
2 | 4 ########################################
3 | 2 ##############                           <- ?
```

**Animacja HTML (2).** Jeden samodzielny plik (działa bez internetu): słupki, przyciski
start/pauza/krok/początek/koniec, suwak pozycji i tempa, skróty klawiszowe (spacja, strzałki) oraz bieżące
liczniki porównań, zamian i zapisów. Kolory: żółty = porównanie, czerwony = zamiana lub zapis, zielony = wynik.
Przy długich przebiegach (powyżej 6000 kroków) animacja pokazuje początek i wynik.

**Porównanie (3).** Ta sama tablica sortowana każdym algorytmem; dla każdego liczba porównań, zamian i
zapisów oraz `ok`, jeśli wynik jest posortowaną permutacją wejścia (sprawdzane niezależnym sortowaniem).

```
n = 8, dane: 5 3 8 1 9 2 7 4
algorytm            porownania   zamiany    zapisy
babelkowe                   25        14         0   ok
przez wstawianie            19        14         0   ok
przez wybieranie            28         6         0   ok
przez scalanie              17         0        24   ok
szybkie                     15         8         0   ok
przez kopcowanie            26        18         0   ok
```

## Jak to jest zbudowane

```
src/
├── src.dk          # wejście, dane (losowe, malejące, rosnące), tryby, kontrola wyniku
├── algorytmy.dk    # sześć algorytmów; każde porównanie/zamiana/zapis idzie do śladu
├── slad.dk         # klasa Slad: liczniki, klatki terminala, zapis klatek do animacji
└── html.dk         # samodzielna strona HTML z odtwarzaczem animacji
```

Algorytmy nie wiedzą, w jakim trybie działa program: wołają `mniejsze`, `zamien` i `zapisz`, a ślad
decyduje, czy narysować klatkę, zapamiętać ją do animacji, czy tylko policzyć operację.

## Testy

```bash
scripts/test.sh
```

13 przypadków w `tests/cases/` (porównania na różnych danych, klatki terminala, animacja HTML, błędne
parametry; `*.code` to oczekiwany kod zakończenia). Liczniki operacji i kolejność kroków zostały dodatkowo
sprawdzone niezależnym modelem w Pythonie na ponad 500 losowych tablicach. CI buduje projekt oficjalnym
Ducklingiem 0.3, uruchamia testy i zapisuje animacje jako artefakt przebiegu `animacje-sortowania`.

## Licencja

MIT (`LICENSE`). Duckling ma własną licencję (DuckType Compiler License 1.0, zob.
[repozytorium języka](https://github.com/ducktype-org/duckling/blob/HEAD/LICENSE.md)).
