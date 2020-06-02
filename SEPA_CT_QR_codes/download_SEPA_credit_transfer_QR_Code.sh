#!/bin/bash
#
# 2020 Sebastiaan Ammerlaan

INVOICE_NUMBER=''
GNUCASH_DATABASE=''
INVOICE_DIRECTORY=''
BANK_ACCOUNT=''
INFO_FIELD=''
BANK_OWNER=''
verbose='0'

# Print help message on -h flag
HELP="$(basename "$0") <-i FILE> <-g FILE> <-o DIR> <-b INPUT> <-t INPUT> <-n INPUT> [-h] [-v] -- bash script that takes a GnuCash invoice number, database file and output directory, then downloads a SEPA Credit Transfer QR code to the output directory.

where:
    -h  Show this help text
    -i  Give GnuCash input number
    -g  Give GnuCash database file location (*.gnucash)
    -o  Give desired output location
    -b  Give IBAN bank account number
    -t  Give text to print in the QR code's info field
    -n  Give IBAN bank account owner's name
    -v  Print some semi-helpful verbose messages."

# Configure flags. A colon after a flag means it expects an argument.
while getopts 'i:g:o:b:t:n:vh' flag; do
  case "${flag}" in
    i) INVOICE_NUMBER="${OPTARG}" ;;
    g) GNUCASH_DATABASE="${OPTARG}" ;;
    o) OUTPUT_DIRECTORY="${OPTARG}" ;;
    b) BANK_ACCOUNT="${OPTARG}" ;;
    t) INFO_FIELD="${OPTARG}" ;;
    n) BANK_OWNER="${OPTARG}" ;;
    v) verbose='1' ;;
    h) echo "$HELP"
       exit
       ;;
    *) echo "$HELP"
       exit 1 ;;
  esac
done
# "it’s OK to set a constant in getopts or based on a condition, but it should be made readonly immediately afterwards"
readonly INVOICE_NUMBER
readonly GNUCASH_DATABASE
readonly OUTPUT_DIRECTORY
readonly BANK_ACCOUNT
readonly INFO_FIELD
readonly BANK_OWNER

# Define verbose function

function log () {
    if [[ $verbose -eq 1 ]]; then
        echo "$@"
    fi
}

DATE=$(date +%d-%m-%Y)

TEMPLATE_INPUT="https://epc-qr.eu/?iban=$BANK_ACCOUNT&euro=@{amount_gross}&bname=$BANK_OWNER&info=$INFO_FIELD"

log "Invoice number: $INVOICE_NUMBER"
log "GnuCash Database file: $GNUCASH_DATABASE"
log "Output directory: "$OUTPUT_DIRECTORY""
log "TEMPLATEINPUT = $TEMPLATE_INPUT"

QR_URL=`(create_gcinvoice -g $GNUCASH_DATABASE -t "$TEMPLATE_INPUT" -o /dev/stdout $INVOICE_NUMBER)`

log "Contents of QR_URL: "$QR_URL""
# Replace spaces by %20:
QR_URL=${QR_URL// /%20}
log "Contents of QR_URL after replacing spaces: "$QR_URL""

# Suppress output from wget except errors.
wget -O ""$OUTPUT_DIRECTORY"/Invoice_"$INVOICE_NUMBER"_SEPACTQR.png" $QR_URL 2>&1 | grep -i "failed\|error"

echo "SEPA Credit Transfer QR code saved as "$OUTPUT_DIRECTORY"/Invoice_"$INVOICE_NUMBER"_SEPACTQR.png"
