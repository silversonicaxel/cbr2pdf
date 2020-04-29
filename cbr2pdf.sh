#! /bin/sh -

export SUCCESS_STYLE=$'\e[1;32m'
export ERROR_STYLE=$'\e[1;31m'
export END_STYLE=$'\e[0m'
export BR=$'\n'

_is_existing_file()
{
    if test -f "$1"; then
        return 0
    fi
    return 1
}

_is_valid_cb_file()
{
    ALLOWED_EXTENSIONS=()
    ALLOWED_EXTENSIONS+=('cbr')
    ALLOWED_EXTENSIONS+=('cbz')
    LENGTH_EXTENSION=${#2}
    CHECKER_EXTENSION=$(( LENGTH_EXTENSION + 1 ))

    if [[ "${1: -$CHECKER_EXTENSION}" == ".$2" ]] && [[ " ${ALLOWED_EXTENSIONS[*]} " == *"$2"* ]] ; then
        return 0
    fi
    return 1
}

ORIGINAL_CB_FILE="$1"
ORIGINAL_BASENAME=$(basename -- "$ORIGINAL_CB_FILE")
ORIGINAL_EXTENSION="${ORIGINAL_BASENAME##*.}"
ORIGINAL_BASENAME="${ORIGINAL_BASENAME%.*}"

if ! _is_existing_file "$ORIGINAL_CB_FILE" ; then
    printf "${ERROR_STYLE}Error. The parsed file $1 does not exist!${END_STYLE}${BR}" 1>&2 && exit 1
fi

if ! _is_valid_cb_file "$ORIGINAL_CB_FILE" "$ORIGINAL_EXTENSION" ; then
    printf "${ERROR_STYLE}Error. The parsed file $1 is not a valid comic book file due to its extension ${ORIGINAL_EXTENSION}!${END_STYLE}${BR}" 1>&2 && exit 1
fi

mkdir -p .cb2pdf

ORIGINAL_CB_FILE=$( echo "$ORIGINAL_CB_FILE" | sed 's/ /\\ /g' )
ORIGINAL_BASENAME=$( echo "$ORIGINAL_BASENAME" | sed 's/ /\\ /g' )
ORIGINAL_EXTENSION=$(printf "%s" "$ORIGINAL_EXTENSION" | tr "[:upper:]" "[:lower:]")

eval cp "$ORIGINAL_CB_FILE" ".cb2pdf/"

COPIED_CBR_FILE=".cb2pdf/$ORIGINAL_CB_FILE"
COPIED_RAR_FILE=".cb2pdf/$ORIGINAL_BASENAME.rar"
COPIED_PDF_FILE="$ORIGINAL_BASENAME.pdf"

eval mv "$COPIED_CBR_FILE" "$COPIED_RAR_FILE"

eval unrar e "$COPIED_RAR_FILE" ".cb2pdf/" > /dev/null 2>&1

rm -f "$COPIED_PDF_FILE"
eval convert ".cb2pdf/*.jpg" ".cb2pdf/*.JPG" "$COPIED_PDF_FILE" > /dev/null 2>&1

rm -rf .cb2pdf

printf "${SUCCESS_STYLE}The $ORIGINAL_CB_FILE is converted to $COPIED_PDF_FILE!${END_STYLE}${BR}"
