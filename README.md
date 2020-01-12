# awkvolby

Modul GNU awk pro zpracování voleb a argumentů na příkazové řádce

## Použití

1. Na začátek svého skriptu vložte `@include "./awkvolby.awk"` a soubor „awkvolby.awk“ umístěte do aktuálního adresáře.
2. Ve svém skriptu (ideálně v bloku BEGIN) deklarujte povolené volby pomocí funkcí `DeklarovatVolbu()` a `DeklarovatAliasVolby()`.
3. Zavolejte funkci `ZpracovatParametry()`.
4. Zpracované parametry najdete v polích `PREPINACE`, `ARGUMENTY` a `PREP_VOLBY`.

## Referenční příručka

    DeklarovatVolbu(název_volby, [alias], [příznaky], [nápověda]);

* Název volby: `"a"` deklaruje volbu „-a“; `"abc"` (tzn. víc než jeden znak) deklaruje volbu „--abc“; `"+x"` a `"+xyz"` deklaruje volby „+x“ a „+xyz“. Název volby je povinný a musí mít jeden z podporovaných tvarů.
* Alias je nepovinný; viz funkci `DeklarovatAliasVolby()`.
* Příznaky jsou řetězec jednotlivých znaků s funkčním významem; v současnosti jsou podporovány tyto příznaky: **p** − volba přijímá parametr; **1** − volba se nesmí opakovat.
* Nápověda je volitelný text popisující volbu. V této verzi je nevyužita, takže je její zadání nepovinné.

.

    DeklarovatAliasVolby(název_volby, alias);

Tato funkce vytvoří k již deklarované volbě alias čili alternativní jméno. Bude-li na příkazovém řádku volba uvedena svým aliasem, před dalším zpracováním se tento alias přeloží na základní jméno volby.

    ZpracovatParametry([příznaky]);

Tato funkce přijímá vlastní sadu příznaků. Podporovány jsou tyto: **0** − Po ukončení zpracování posune celé pole `ARGUMENTY` o jeden index dolů a do prvku `ARGUMENTY[0]` přiřadí prázdný řetězec. **m** − Povolí míchání voleb a argumentů, pokud argumenty nebudou začínat „+“ nebo „-“. (Normálně se zpracování voleb ukončí prvním parametrem z `ARGV`, který nemá tvar volby.)

Po skončení funkce ZpracovatParametry() budete mít k dispozici nová pole:

* `PREPINACE[]` obsahuje na indexech 1 až `POCET_PREPINACU` (základní) názvy voleb v pořadí, jak byly rozpoznány. Pokud určitá volba přijímá parametr, jeho hodnota je uložena v prvku `POCET_PREPINACU[i "p"]`, kde `i` je index přepínače.
* `ARGUMENTY[]` obsahuje na indexech 1 až `POCET_ARGUMENTU` parametry z ARGV následující po poslední volbě, resp. po oddělovači `--`.
* `PREP_VOLBY[]` je asociativní pole, které jako klíče obsahuje základní názvy voleb, jak byly zadány. Pro volby, které nepřijímají parametr, je hodnotou prázdný řetězec; pro volby, které parametr přijímají, je to hodnota parametru. (Pokud se parametr opakuje, je to vždy poslední hodnota daného parametru.)

## Příklady

Zpracování parametrů:

    DeklarovatVolbu("a", "abeceda");
    DeklarovatVolbu("c");
    DeklarovatVolbu("dlouha-volba");
    DeklarovatVolbu("+s-parametrem", "", "p");
    DeklarovatAliasVolby("a", "Abeceda");
    ZpracovatParametry();

Příklad volání gawk:

    gawk -f skript.awk -- -ca --Abeceda --dlouha-volba +s-parametrem=123 "První argument" "Druhý argument"

Test, zda byl zadán parametr `-a`, `--abeceda` nebo `--Abeceda`:

    if ("a" in PREP_VOLBY) {...}

## Rozpoznávané tvary parametrů

Volby ve tvaru „-“ a jeden další znak (pokud možno alfanumerický) jsou tzv. krátké volby. Krátké volby lze seskupit do jednoho parametru (např. `-abc`), pokud nepřijímají parametr, popř. pokud parametr přijímá jen poslední z nich. Pokud krátká volba přijímá parametr, lze ho zadat jedním z těchto způsobů:

* -x*parametr* (jen pokud je parametr neprázdný a nezačíná znakem „=“)
* -x=*parametr*
* -x *parametr*

Volby ve tvaru „--“ a další znaky nebo „+“ a další znaky jsou tzv. dlouhé volby. Pokud přijímají parametr, lze jim ho předat dvěma způsoby:

* --volba=*parametr* (a analogicky +volba=*parametr*)
* --volba *parametr* (a analogicky +volba *parametr*)
