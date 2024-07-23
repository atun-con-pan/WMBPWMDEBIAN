#!/bin/bash
fecha=$(LC_TIME=es_ES.utf8 date +'%d %b %Y' | sed 's/Jan/Ene/;s/Feb/Feb/;s/Mar/Mar/;s/Apr/Abr/;s/May/May/;s/Jun/Jun/;s/Jul/Jul/;s/Aug/Ago/;s/Sep/Sep/;s/Oct/Oct/;s/Nov/Nov/;s/Dec/Dic/')
hora=$(LC_TIME=es_ES.utf8 date +'%l:%M')
ampm=$(LC_TIME=es_ES.utf8 date +'%p')
echo "$fecha | $hora $ampm"
