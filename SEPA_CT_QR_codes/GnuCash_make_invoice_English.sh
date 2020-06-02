#!/bin/bash
# This script asks for an invoice number, passes that to gcinvoice for LaTeX, makes that into a new .tex file
# and then makes a .pdf file with the invoice number and date in the file name.
# The user is then prompted to open the pdf file.
#
# Fill in the location of your GnuCash-database and your template below, as well as where you want your invoices
# to be placed.


clear

echo "Fill in invoice number"

read FACTUURNUMMER

DATUM=$(date +%d-%m-%Y)

# Check if FACTUURNUMMER is a number
case $FACTUURNUMMER in 
    ''|*[!0-9]*) echo "This is not a number. Try again."; exit 1 ;;
    *) echo "Invoice number: "$FACTUURNUMMER, date: $DATUM ;;
esac

# Fill in the location of your GnuCash-database below:
GNUCASHDATABASE="/location/of/database.gnucash"

# Fill in the location of your template below:
GCINVOICETEMPLATE="/location/of/template.tex"

# Fill in where you want your created invoices to be placed below:
FACTURENMAP="/location/of/target/directory/"

read -p "Do you want a SEPA Credit Transfer QR-code on your invoice? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    bash download_SEPA_credit_transfer_QR_Code.sh -i "$FACTUURNUMMER" -g "$GNUCASHDATABASE" -o "$FACTURENMAP"/QR_codes_SEPA/
fi

create_gcinvoice -g "$GNUCASHDATABASE" -t "$GCINVOICETEMPLATE" -o "$FACTURENMAP"/Invoice_"$FACTUURNUMMER"_"$DATUM".tex  $FACTUURNUMMER

echo File made: "$FACTURENMAP"/Invoice_"$FACTUURNUMMER"_"$DATUM".tex

# Make .pdf file
# Filter all output except errors
lualatex -shell-escape -file-line-error -synctex=1 -interaction=nonstopmode -output-directory="$FACTURENMAP" "$FACTURENMAP"/Invoice_"$FACTUURNUMMER"_"$DATUM".tex | grep ".*:[0-9]*:.*"

echo File made: "$FACTURENMAP"/Invoice_"$FACTUURNUMMER"_"$DATUM".pdf

# Repress annoying Evince errors
alias evince='evince 2> >( grep -v "evince.*WARNING" >&2 )'

# Ask if user wants to open pdf file
read -p "Would you like to open the pdf file? (y/n) " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    evince "$FACTURENMAP"/Invoice_"$FACTUURNUMMER"_"$DATUM".pdf 2> >( grep -v "evince.*WARNING" >&2 ) # do dangerous stuff
fi
