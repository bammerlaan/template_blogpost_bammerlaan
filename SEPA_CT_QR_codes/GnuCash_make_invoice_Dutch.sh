#!/bin/bash
# Dit script neemt factuurnummer in, stuurt dat naar gcinvoice voor LaTeX, maakt er een LaTeXbestand van en 
# maakt daar vervolgens een .pdf-bestand van met in de bestandsnaam het factuurnummer en de datum.
# Het programma biedt vervolgens de keuze om het pdf-bestand weer te geven.
# 
# Vul hieronder de locatie van je GnuCash-database en je LaTeX-sjabloon in. Geef ook aan in welke map je 
# je facturen geplaatst wilt hebben.


# Global constants:
# Fill in the location of your GnuCash-database below:
GNUCASHDATABASE="/location/of/database.gnucash"

# Fill in the location of your template below:
GCINVOICETEMPLATE="/location/of/template.tex"

# Fill in where you want your created invoices to be placed below:
# QR codes will be saved to a subdirectory of this directory, called "QR_codes_SEPA/". You may need to create this directory first.
FACTURENMAP="/location/of/target/directory/"

# Fill in IBAN bank account number
BANK_ACCOUNT="NL44ASNB0942331508"

# Fill in bank account owner:
BANK_OWNER="Bas Ammerlaan, zanger"

# Fill in what you want in the info field of the payment (now shows name of client and invoice number): 
INFO_FIELD="@{owner['full_name']}, invoice number: @{id}"

clear

echo "Vul het factuurnummer in"

read FACTUURNUMMER

DATUM=$(date +%d-%m-%Y)

# Controleer of FACTUURNUMMER een getal is
case $FACTUURNUMMER in 
    ''|*[!0-9]*) echo "Dit is geen getal. Probeer opnieuw!"; exit 1 ;;
    *) echo "Factuurnummer: "$FACTUURNUMMER, datum: $DATUM ;;
esac



read -p "Wil je een SEPA Credit Transfer QR-code op je factuur? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    bash download_SEPA_credit_transfer_QR_Code.sh -i "$FACTUURNUMMER" -g "$GNUCASHDATABASE" -o "$FACTURENMAP"/QR_codes_SEPA/ -b "$BANK_ACCOUNT" -t "$INFO_FIELD" -n "$BANK_OWNER"
fi

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
