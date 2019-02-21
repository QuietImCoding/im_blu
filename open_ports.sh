oldifs=$IFS
IFS=" "
netdump="$(netstat -ltun | awk -F' ' 'NR > 2 { printf("%s %s\n", $1, $4 ) }' | sort | uniq) "
ports=$(echo $netdump | rev | cut -d':' -f 1 | rev)
type=$(echo $netdump | cut -d' ' -f 1)
IFS=$oldifs
spaces=`echo $ports | sed 's/[^ ]//g'`
for k in `seq ${#spaces}`
do 
    printf "`echo $type | cut -d' ' -f $k`\t`echo $ports | cut -d' ' -f $k` \n" 
done






