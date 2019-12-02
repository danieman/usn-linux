#!/bin/bash

# diskrydding: et program som rydder store filer på disk

LOGGFIL=diskrydding.log
PROGNAME=$(basename $0)

usage () {
    echo
    echo "$PROGNAME: usage: $PROGNAME <min filesize> ( -i | (-d <directory> [-r]) )"
    echo "Examples:"
    echo -e "\t\$ $PROGNAME 200M -i"
    echo -e "\t\$ $PROGNAME 1G -d /home/daniel/"
    echo -e "\t\$ $PROGNAME 500M -d /home/daniel -r"
    return
}

if [[ $1 =~ ^[[:digit:]]+[k|M|G]$ ]]; then
    FILESIZE=$1
    shift
else
    echo "Filesize must be written in human readable format (e.g. 500k, 50M or 5G)." >&2
    usage >&2
    exit 1
fi

if [[ $1 == "-i" || $1 == "--interactive" ]]; then
    interactive=true
else
    interactive=false
    recursive=false
    while [[ -n $1 ]]; do
        case $1 in
            -d | --directory)   shift
                                directory=$1
                                ;;
            -h | --help)        usage
                                exit
                                ;;
            -r | --recursive)   recursive=true
                                ;;
            *)                  usage >&2
                                exit 1
                                ;;
        esac
        shift
    done
fi

if $interactive; then
    echo "Interactive it is!"
    until [[ -d $directory ]]; do
        read -e -p "Which directory would you like to clean? " -i "$(pwd)" directory
    done

    while true; do
        read -p "Do you want to clean recursively? " svar
        if [[ $svar =~ ^[yY](es|ES)?$ ]]; then
            recursive=true
            break
        elif [[ $svar =~ ^[nN][oO]*$ ]]; then
            recursive=false
            break
        else
            echo
            echo "Please answer Yes or No (y/n)."
        fi
    done
    echo
else
    # Sanity check
    if [[ ! -d $directory ]]; then
        echo "A directory must be specified." >&2
        usage >&2
        exit 1
    fi
fi

OLD_IFS="$IFS"
IFS=$'\n'
if $recursive; then
    big_files=$(find $directory -type f -size +${FILESIZE})
else
    big_files=$(find $directory -maxdepth 1 -type f -size +${FILESIZE})
fi

for file in $big_files; do
    choice=
    if [[ -f $file ]]; then
        size=$(du -h $file | cut -f1)
        echo "The following file has a size of $size: $file"
        while [[ ! $choice =~ ^[1-3]$ ]]; do
            read -p "Do you want to: 1) delete, 2) compress, or 3) ignore? " choice
        done
        if [[ $choice == 1 ]]; then
            rm -i $file
            if [[ ! -f $file ]]; then
                echo "Deleted file of size $size: $file" | tee -a $LOGGFIL
            else
                echo "Ignored file: $file" | tee -a $LOGGFIL
            fi
        elif [[ $choice == 2 ]]; then
            gzip $file
            echo "Compressed file $file ($size) into $file.gz ($(du -h ${file}.gz | cut -f1))" | tee -a $LOGGFIL
        else
            echo "Ignored file of size $size: $file" | tee -a $LOGGFIL
            echo "Moving on..."
        fi
        echo
    fi
done
IFS="$OLD_IFS"

echo
echo "Job completed."
echo "Cleanup logs stored in file $LOGGFIL."