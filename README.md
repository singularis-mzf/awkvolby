# awkvolby

Modul GNU awk pro zpracování voleb a argumentů na příkazové řádce

## Použití

1. Na začátek svého skriptu vložte `@include "./awkvolby.awk"` a soubor „awkvolby.awk“ umístěte do aktuálního adresáře.
2. Ve svém skriptu (ideálně v bloku BEGIN) deklarujte povolené volby pomocí funkcí `DeklarovatVolbu()` a `DeklarovatAliasVolby()`.
3. Zavolejte funkci `ZpracovatParametry()`.
4. Zpracované parametry najdete v polích `PREPINACE`, `ARGUMENTY` a `PREP_VOLBY`.

## Referenční příručka

    DeklarovatVolbu(název_volby, [alias], [příznaky], [skupina], [nápověda]);

* Název volby: hlavní název volby. Musí mít jeden z podporovaných tvarů: „-x“, „--řetězec“ nebo „+řetězec“.
* Alias je nepovinný; viz funkci `DeklarovatAliasVolby()`.
* Příznaky jsou řetězec jednotlivých znaků s funkčním významem, viz níže.
* Skupina je identifikátor skupiny. Je-li zadán, pak se v případě výskytu dané volby nastaví „PREP_SKUPINY[*skupina*]“ na název volby a z pole PREP_VOLBY se odstraní jakákoliv jiná volba z téže skupiny. Na pole PREPINACE nemají skupiny vliv.
* Nápověda je volitelný text popisující volbu. V této verzi je nevyužita, takže je její zadání nepovinné.

Podporované příznaky:

* 1 − Volba se nesmí opakovat. Vylučuje se s [c].
* c − Volba typu „počítadlo“. Nepřijímá parametr, ale jako fiktivní parametr vrací počet svých výskytů (s každým výskytem se inkrementuje). Vylučuje se s [1cpP].
* g − Byla-li již zadána jiná volba z téže skupiny, je to fatální chyba. (Normálně se předchozí volba přepíše.)
* p − Volba vyžaduje parametr. Vylučuje se s [cv].
* P − Volba vyžaduje neprázdný parametr. Vylučuje se s [cv].
* v − Volba přijímá volitelný parametr (lze zadat pouze v rámci stejného argumentu). Vylučuje se s [cpP].
.

    DeklarovatAliasVolby(název_volby, alias);

Tato funkce vytvoří k již deklarované volbě alias čili alternativní jméno. Bude-li na příkazovém řádku volba uvedena svým aliasem, před dalším zpracováním se tento alias přeloží na základní jméno volby. Pro aliasy jsou podporovány stejné tvary jako pro názvy voleb.

    ZpracovatParametry([příznaky]);

Tato funkce přijímá vlastní sadu příznaků:

* 0 − Po ukončení zpracování posune celé pole `ARGUMENTY` o jeden index dolů (tzn. do rozsahu indexů 0 až POCET_ARGUMENTU - 1) a do prvku `ARGUMENTY[POCET_ARGUMENTU]` přiřadí prázdný řetězec.
* m − Povolí míchání voleb a argumentů, pokud argumenty nebudou začínat „+“ nebo „-“. (Normálně se zpracování voleb ukončí prvním parametrem z `ARGV`, který nemá tvar volby.)
* ! − Zakáže tvary „--volba=parametr“ a „+volba=parametr“.

Po skončení funkce ZpracovatParametry() budete mít k dispozici nová pole:

* `PREPINACE[]` obsahuje na indexech 1 až `POCET_PREPINACU` (základní) názvy voleb v pořadí, jak byly rozpoznány. Pokud určitá volba přijímá parametr a byl zadán, jeho hodnota je uložena v prvku `POCET_PREPINACU[i "p"]`, kde `i` je index přepínače.
* `ARGUMENTY[]` obsahuje na indexech 1 až `POCET_ARGUMENTU` parametry z ARGV následující po poslední volbě, resp. po oddělovači `--`.
* `PREP_SKUPINY[]` je asociativní pole. Pro každou skupinu, ze které byla zadána nějaká volba, uvádí název poslední zadané volby. Pro skupiny, ze kterých nebyla zadána žádná volba, neobsahuje prvek.
* `PREP_VOLBY[]` je asociativní pole, které jako klíče obsahuje základní názvy voleb, jak byly zadány. Pro volby, které nepřijímají parametr, je hodnotou prázdný řetězec; pro volby, které parametr přijímají, je to hodnota parametru. (Pokud se parametr opakuje, je to vždy poslední hodnota daného parametru.)

## Příklady

Zpracování parametrů:

    # název alias příznaky skupina nápověda
    DeklarovatVolbu("-a", "abeceda");
    DeklarovatVolbu("-c");
    DeklarovatVolbu("--dlouha-volba");
    DeklarovatVolbu("+s-parametrem", "", "p");
    DeklarovatVolbu("+rezim1", "", "", "rezim");
    DeklarovatVolbu("+rezim2", "", "", "rezim");
    DeklarovatAliasVolby("-a", "--Abeceda");
    ZpracovatParametry();

Příklad volání gawk:

    gawk -f skript.awk -- -ca --Abeceda --dlouha-volba +s-parametrem=123 +rezim1 "První argument" "Druhý argument"

Test, zda byl zadán parametr `-a`, `--abeceda` nebo `--Abeceda`:

    if ("a" in PREP_VOLBY) {...}

## Rozpoznávané tvary parametrů

Volby ve tvaru „-“ a jeden další znak (pokud možno alfanumerický) jsou tzv. krátké volby. Krátké volby lze seskupit do jednoho parametru (např. `-abc`), pokud nepřijímají parametr, popř. pokud parametr přijímá jen poslední z nich. Pokud krátká volba přijímá parametr, lze ho zadat jedním z těchto způsobů:

* -x*parametr* (tímto způsobem nelze zadat prázdný řetězec!)
* -x *parametr* (jen pro povinný parametr)

Volby ve tvaru „--“ a další znaky nebo „+“ a další znaky jsou tzv. dlouhé volby. Pokud přijímají povinný parametr, lze jim ho předat dvěma způsoby:

* --volba=*parametr*
* --volba *parametr* (jen pro povinný parametr)
* +volba=*parametr*
* +volba *parametr* (jen pro povinný parametr)

## Náměty na zlepšení

* Přijímá-li volba volitelný parametr, umožnit deklarovat jeho výchozí hodnotu.
