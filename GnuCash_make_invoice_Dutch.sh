#!/bin/bash
# Dit script neemt factuurnummer in, stuurt dat naar gcinvoice voor LaTeX, maakt er een LaTeXbestand van en 
# maakt daar vervolgens een .pdf-bestand van met in de bestandsnaam het factuurnummer en de datum.
# Het programma biedt vervolgens de keuze om het pdf-bestand weer te geven.
# Vul hieronder de locatie van je GnuCash-database en je sjabloon in, en de locatie waar je je facturen geplaatst wilt hebben.


clear

echo "Vul het factuurnummer in"

read FACTUURNUMMER

DATUM=$(date +%d-%m-%Y)

# Controleer of FACTUURNUMMER een getal is
case $FACTUURNUMMER in 
    ''|*[!0-9]*) echo "Dit is geen getal. Probeer opnieuw!"; exit 1 ;;
    *) echo "Factuurnummer: "$FACTUURNUMMER, datum: $DATUM ;;
esac

# Vul hier de locatie van je GnuCash-Database in:
GNUCASHDATABASE="/home/steelbas/Documents/Bestanden/Bestanden/bammerlaan_zangles/Gnucash_boekhouding/Boekhouding_Bas_Ammerlaan,_Zanger.gnucash"

# Vul hier de locatie van je LaTeX-sjabloon in:
GCINVOICETEMPLATE="/home/steelbas/Documents/Bestanden/Bestanden/bammerlaan_zangles/Gnucash_boekhouding/Facturen/LaTeX_template/invoice.tex"

# Vul hier in waar je je facturen geplaatst wilt hebben:
FACTURENMAP="/home/steelbas/Documents/Bestanden/Bestanden/bammerlaan_zangles/Gnucash_boekhouding/Facturen/LaTeX/"

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
