#!/usr/bin/env bash

# check_dump1090
#
# Author: Zoltan RUZSOM <ruzsom.zoltan@gmail.com>

OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

usage()
{
/usr/bin/cat <<EOF

    Nagios plugin to checking dump1090 stats.

	Options:
        -h this page.
        -p Path to stats.json
        -m Check the number of ADSB messages.

        -w Warning value.
        -c Critical value.
EOF

exit $UNKNOWN

}

check_messages()
{
    if [[ $1 -eq 1 ]]; then
        msgs=$(/usr/bin/jq '.last1min.messages' $path)
    elif [[ $1 -eq 5 ]]; then
        msgs=$(/usr/bin/jq '.last5min.messages' $path)
    elif [[ $1 -eq 15 ]]; then
        msgs=$(/usr/bin/jq '.last15min.messages' $path)
    fi

    if [[ $msgs -lt $critical_value ]]; then
        echo "CRITICAL: $1 min messages: $msgs"
        exit $CRITICAL
    elif [[ $msgs -lt $warning_value ]]; then
        echo "WARNING: $1 min messages: $msgs"
        exit $WARNING
    else
        echo "OK: $1 min messages: $msgs"
        exit $OK
    fi
}

if [ $# -eq 0 ]; then
    echo ""
    echo "check_dump1090 ERROR: required parameters missing"
    usage
fi

while getopts "hm:c:w:p:" opts
do
    case $opts in
        h)
            usage
            exit 0
            ;;
        m)
            if [[ $OPTARG -ne 1 && $OPTARG -ne 5 && $OPTARG -ne 15 ]]; then
                echo ""
                echo "check_dump1090 PARAMETER ERROR"
                echo "  Valid values for -m option are: 1, 5, 15"
                usage
            fi
            check_for="$OPTARG"
            ;;
        c)
            critical_value="$OPTARG"
            ;;
        w) 
            warning_value="$OPTARG"
            ;;
        p) 
            path="$OPTARG"
    esac
done

if [ -z $check_for ]; then
    echo ""
    echo "check_dump1090: Required parameter -m missing."
    usage
fi

check_messages $check_for
