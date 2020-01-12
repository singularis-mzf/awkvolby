# awkvolby − Modul GNU awk pro zpracování voleb a argumentů na příkazové řádce
#
# Copyright (c) 2020 Singularis
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# Toto dílo je dílem svobodné kultury; můžete ho šířit a modifikovat pod
# podmínkami licence Creative Commons Attribution-ShareAlike 4.0 International
# vydané neziskovou organizací Creative Commons. Text licence je přiložený
# k tomuto projektu nebo ho můžete najít na webové adrese:
#
# https://creativecommons.org/licenses/by-sa/4.0/

#
# Použití:
#
# 1. Vložte tento modul na začátek skriptu příkazem „@include "awkvolby.awk"“.
# 2. Funkcemi DeklarovatVolbu() a DeklarovatAliasVolby() deklarujte,
#    které volby váš skript přijímá.
# 3. Zavolejte funkci ZpracovatParametry().
# 4. Zpracujte volby a argumenty. Volby můžete zpracovat buď sekvenčně, nebo logicky.
#

# Veřejné proměnné:
#
# PREPINACE[1..POCET_PREPINACU] = "název volby"
# PREPINACE[1 "h"..POCET_PREPINACU "h"] = "hodnota volby"
# ARGUMENTY[1..POCET_ARGUMENTU] = "text argumentu"
# PREP_VOLBY["název volby"] = "poslední hodnota volby" # "", pokud nepřijímá hodnoty

#
# Soukromé proměnné:
#
# awkvolby_aliasy["alias"] => "název volby"
# awkvolby_priznaky["název volby"] => "příznaky"
# awkvolby_napoveda["název volby"] => "název,alias,alias,...|text nápovědy"
#

#
# Příznaky:
#   1 − Parametr se nesmí opakovat.
#   h − Parametr přijímá (vyžaduje) hodnotu.
#
function DeklarovatVolbu(nazev, alias, priznaky, napoveda,   i) {
    if (!awkvolby_jenazevvolby(nazev)) {awkvolby_chyba("Chybějící či neplatný název volby!")}
    if (alias != "" && !awkvolby_jenazevvolby(alias)) {awkvolby_chyba("Neplatný alias volby!")}

    awkvolby_priznaky[nazev] = priznaky;
    awkvolby_napoveda[nazev] = nazev "|" napoveda;

    if (alias != "") {DeklarovatAliasVolby(nazev, alias)}
    return 0;
}

function DelarovatAliasVolby(nazev, alias) {
    if (!awkvolby_jenazevvolby(nazev)) {awkvolby_chyba("Chybějící či neplatný název volby!")}
    if (alias != "" && !awkvolby_jenazevvolby(alias)) {awkvolby_chyba("Neplatný alias volby!")}
    if (!(nazev in awkvolby_priznaky)) {awkvolby_chyba("Vytvoření aliasu selhalo, protože volba „" nazev "“ nebyla deklarována.")}
    if (alias in awkvolby_aliasy) {awkvolby_chyba("Alias " alias " již byl deklarován.")}

    awkvolby_aliasy[alias] = nazev;
    sub(/\|/, "," alias "|", awkvolby_napoveda[nazev]);
    return 0;
}

#
# Příznaky:
#   0 − po ukončení zpracování posune celé pole ARGUMENTY o jeden index dolů,
#       takže první argument bude ARGUMENTY[0]; ARGUMENTY[POCET_ARGUMENTU] = ""
#   m − „mixed“: povolí míchání voleb a argumentů nezačínajících „+“ nebo „-“
#
function ZpracovatParametry(priznaky,   i, i_hodnoty, j, nazev) {
    POCET_ARGUMENTU = POCET_PREPINACU = 0;
    delete ARGUMENTY;
    delete PREPINACE;
    delete PREP_VOLBY;

    i = 1;
    while (i < ARGC && ARGV[i] != "--") {
        if (ARGV[i] ~ /^(--|\+)[^-+=|]/) {
            # Dlouhý parametr (tvary „--název“, „--název=hodnota“, „--název hodnota“, „+název“, „+název=hodnota“, „+název hodnota“)
            i_hodnoty = index(ARGV[i], "=");
            if (ARGV[i] ~ /^\+/) {
                nazev = i_hodnoty ? substr(ARGV[i], 1, i_hodnoty - 1) : ARGV[i];
            } else {
                nazev = i_hodnoty ? substr(ARGV[i], 3, i_hodnoty - 3) : substr(ARGV[i], 3);
            }
            if (nazev in awkvolby_aliasy) {nazev = awkvolby_aliasy[nazev]}
            if (!(nazev in awkvolby_priznaky)) {
                # Neznámá volba
                awkvolby_chyba("Neznámá volba: " ARGV[i]);
            }
            PREPINACE[++POCET_PREPINACU] = nazev;
            if (awkvolby_priznaky[nazev] ~ /1/ && nazev in PREP_VOLBY) {
                awkvolby_chyba("Parametr " nazev " se nesmí opakovat.");
            }
            PREP_VOLBY[nazev] = "";
            if (awkvolby_priznaky[nazev] !~ /h/) {
                # Nepřijímá hodnotu
                if (i_hodnoty) {awkvolby_chyba("Nadbytečná hodnota k parametru: " ARGV[i])}
            } else if (i_hodnoty) {
                # Hodnota je již vyplněna
                PREP_VOLBY[nazev] = PREPINACE[POCET_PREPINACU "h"] = substr(ARGV[i], i_hodnoty + 1);
            } else if (i + 1 != ARGC) {
                PREP_VOLBY[nazev] = PREPINACE[POCET_PREPINACU "h"] = ARGV[++i];
            } else {
                awkvolby_chyba("Chybí hodnota k parametru: " ARGV[i]);
            }
        } else if (ARGV[i] ~ /^-[^-+=|]/) {
            # Krátký parametr (tvar „-n“, „-mnop“, „-mhodnota“)
            j = 2;
            while (j <= length(ARGV[i])) {
                nazev = substr(ARGV[i], j, 1);

                if (nazev in awkvolby_aliasy) {nazev = awkvolby_aliasy[nazev]}
                if (!(nazev in awkvolby_priznaky)) {
                    # Neznámá volba
                    awkvolby_chyba("Neznámá volba: " ARGV[i]);
                }
                PREPINACE[++POCET_PREPINACU] = nazev;
                if (awkvolby_priznaky[nazev] ~ /1/ && nazev in PREP_VOLBY) {
                    awkvolby_chyba("Parametr " nazev " se nesmí opakovat.");
                }
                PREP_VOLBY[nazev] = "";
                if (awkvolby_priznaky[nazev] ~ /h/) {
                    if (j < length(ARGV[i])) {
                        # Zbývají nějaké znaky => použít je jako hodnotu.
                        PREP_VOLBY[nazev] = PREPINACE[POCET_PREPINACU "h"] = substr(ARGV[i], 1 + j);
                        break;
                    } else if (i + 1 != ARGC) {
                        PREP_VOLBY[nazev] = PREPINACE[POCET_PREPINACU "h"] = ARGV[++i];
                        break;
                    } else {
                        awkvolby_chyba("Chybí hodnota k parametru „" nazev "“: " ARGV[i]);
                    }
                }
                ++j;
            }
        } else if (ARGV[i] !~ /^[-+]/) {
            if (priznaky ~ /m/) {
                ARGUMENTY[++POCET_ARGUMENTU] = ARGV[i];
            } else {
                break;
            }
        } else {
            awkvolby_chyba("Neplatný tvar volby: " ARGV[i]);
        }
        ++i
    }
    if (i < ARGC && ARGV[i] == "--") {++i}
    while (i < ARGC) {
        ARGUMENTY[++POCET_ARGUMENTU] = ARGV[i++];
    }
    if (priznaky ~ /0/) {
        for (i = 0; i < POCET_ARGUMENTU; ++i) {
            ARGUMENTY[i] = ARGUMENTY[i + 1];
        }
        ARGUMENTY[POCET_ARGUMENTU] = "";
    }
    return POCET_ARGUMENTU + POCET_PREPINACU;
}

function awkvolby_jenazevvolby(nazev) {
    return nazev ~ /^[+-]?[^-+=|]+$/;
}

function awkvolby_chyba(text) {
    printf("awkvolby: %s\n", text) > "/dev/stderr";
    exit 1;
}
