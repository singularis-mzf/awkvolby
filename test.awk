# awkvolby : Automatický test
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

@include "./awkvolby.awk"
BEGIN {
    DeklarovatVolbu("-p", "--param", "p", "Testovací volba s parametrem, která se může opakovat.");
    DeklarovatVolbu("-P", "--print", "", "Jiná testovací volba.");
    DeklarovatVolbu("-v", "--var", "", "Testovací volba bez parametru, která se může opakovat.");
    DeklarovatVolbu("+v", "--nevar", "", "Volba +v = --nevar.");
    DeklarovatVolbu("+nic", "-n", "p", "Dlouhá +volba s -aliasem.");
    DeklarovatAliasVolby("-v", "--war");
    ZpracovatParametry();
    OFS = "";
    for (i = 1; i <= POCET_PREPINACU; ++i) {
        print "prep[", i, "]=<", Precist(PREPINACE, i), "><", Precist(PREPINACE, i "p"), "><", Precist(PREP_VOLBY, Precist(PREPINACE, i)), ">";
    }
    if (0 in ARGUMENTY) {
        print "arg[0]=<", Precist(ARGUMENTY, 0), ">";
    }
    for (i = 1; i <= POCET_ARGUMENTU; ++i) {
        print "arg[", i, "]=<", Precist(ARGUMENTY, i), ">";
    }
    exit;
}

function Precist(pole, klic) {
    return klic in pole ? pole[klic] : "@null@";
}
