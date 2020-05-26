#!/bin/bash
# Dit script neemt factuurnummer in, stuurt dat naar gcinvoice voor LaTeX, maakt er een LaTeXbestand van en 
# maakt daar vervolgens een .pdf-bestand van met in de bestandsnaam het factuurnummer en de datum.
# Het programma biedt vervolgens de keuze om het pdf-bestand weer te geven.
# 
# Vul hieronder de locatie van je GnuCash-database en je LaTeX-sjabloon in. Geef ook aan in welke map je 
# je facturen geplaatst wilt hebben.


clear

echo "Vul het factuurnummer in"

read FACTUURNUMMER

DATUM=$(date +%d-%m-%Y)

# Controleer of FACTUURNUMMER een getal is
case $FACTUURNUMMER in 
    ''|*[!0-9]*) echo "Dit is geen getal. Probeer opnieuw!"; exit 1 ;;
    *) echo "Factuurnummer: "$FACTUURNUMMER, datum: $DATUM ;;
esac

GNUCASHDATABASE="/plaats/van/je/database.gnucash"

GCINVOICETEMPLATE="/plaats/van/je/sjabloon.tex"

FACTURENMAP="/waar/je/je/facturen/wilt/plaatsen/"

create_gcinvoice -g "$GNUCASHDATABASE" -t "$GCINVOICETEMPLATE" -o "$FACTURENMAP"/Factuur_"$FACTUURNUMMER"_"$DATUM".tex  $FACTUURNUMMER

echo Bestand gemaakt: "$FACTURENMAP"/Factuur_"$FACTUURNUMMER"_"$DATUM".tex

# .pdf-bestand maken
# Filter alle output behalve errors
lualatex -shell-escape -file-line-error -synctex=1 -interaction=nonstopmode -output-directory="$FACTURENMAP" "$FACTURENMAP"/Factuur_"$FACTUURNUMMER"_"$DATUM".tex | grep ".*:[0-9]*:.*"

echo Bestand gemaakt: "$FACTURENMAP"/Factuur_"$FACTUURNUMMER"_"$DATUM".pdf

# Onderdruk irritante warnings van Evince
alias evince='evince 2> >( grep -v "evince.*WARNING" >&2 )'

# Vraag of gebruiker PDF-bestand wil openen.
read -p "Wil je het pdf-bestand openen? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    evince "$FACTURENMAP"/Factuur_"$FACTUURNUMMER"_"$DATUM".pdf 2> >( grep -v "evince.*WARNING" >&2 ) # do dangerous stuff
fi
