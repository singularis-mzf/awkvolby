#!/bin/bash -e
# awkvolby: automatický test
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

function predel() { printf "%s %s %s\n" "--" "$1" "---------"; }
function testawk() { command gawk -f ./test.awk -- "$@"; }

# Test bez voleb:
predel 10
testawk >vysledek-1.txt

# Testy s jednou volbou:
predel 20
testawk -v
predel 30
testawk -p1
predel 40
testawk -p=1
predel 50
testawk -p=
predel 60
testawk -p 1
predel 70
testawk --param=1
predel 80
testawk --param 1
predel 90
testawk --param=
predel 100
testawk --param ""
predel 110
testawk +v
predel 120
testawk +nic 1
predel 130
testawk +nic=1
predel 140
testawk +nic ""
predel 150
testawk +nic=

# Testy se dvěma volbami:
predel 200
testawk -v -v
predel 210
testawk -vv
predel 220
testawk -p -- -v
predel 230
testawk -p1 -p2
predel 240
testawk -vp1
predel 250
testawk -vp=1
predel 260
testawk -vp==1
predel 270
testawk -v --param -1
predel 280
testawk --var -p ""
predel 290
testawk --param=1 --param=2
predel 300
testawk --param --param --param 2
predel 310
testawk +nic -- --param 2
predel 320
testawk +nic 1 +nic 2
predel 330
testawk -vn ""

# Testy s jednou volbou a argumenty
predel 410
testawk -v argument
predel 420
testawk -p1 argument
predel 430
testawk -p=1 argument
predel 440
testawk -p= argument
predel 450
testawk -p 1 argument
predel 460
testawk --param=1 argument
predel 470
testawk --param 1 argument
predel 480
testawk --param= argument
predel 490
testawk --param "" argument
predel 500
testawk +v argument
predel 510
testawk +nic 1 argument
predel 520
testawk +nic=1 argument
predel 530
testawk +nic "" argument
predel 540
testawk +nic= argument

# Testy s ručním oddělením argumentů
predel 610
testawk -vv -- -vp1 argument
predel 620
testawk --param -1 -v -- -v --param 1 argument
predel 630
testawk -- -v -vp1 -- -v -p7
predel 640
testawk -vv --
predel 650
testawk -vv -- -
predel 660
testawk -vv -- -- - -- --- ----

# Testy se speciálními znaky v argumentech
predel 800
testawk --param '\' -p '\\'
predel 810
testawk -p $'A\tB' -- $'\n'
predel 820
testawk -p "'\\'" -- '\&&$@#^**!_+@!++-\\*&'
