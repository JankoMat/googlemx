#! /bin/bash
echo "Which domain do you want to change the MX records for?"
read domain
echo

echo "Backing up the DNS zone for $domain"
cp /var/named/$domain.db /home/temp/$domain.bak.db
backup=/home/temp/$domain.bak.db
echo "DNS zone for $domain was backed up to $backup"
echo

echo "Removing existing MX records."
echo


END=$(grep MX /var/named/$domain.db | wc -l)
for ((i=1;i<=END;i++)); do
		mx=$(grep -m1 -n MX /var/named/$domain.db)
                echo "Removing the following record:"
                x=$( echo "$mx" | cut -d : -f 2)
                echo $x
                n=$( echo "$mx" | cut -d : -f 1)
                sed -i "$n"'d' /var/named/$domain.db
done
echo

echo "The MX records were removed, review the output of the script and input y to add Google MX records or n to undo the changes:"
read q
echo

if [ $q == "n" ]
	then
	mv /var/named/$domain.db /home/temp/$domain.failed.bak.db
	mv /home/temp/$domain.bak.db /var/named/$domain.db
	echo "The changes have been reverted, the DNS zone that was worked on is available for review at /home/temp/$domain.failed.bak.db"
	exit 1
fi

if [ $q == "y" ]
	then
cat >> /var/named/$domain.db << EOF
$domain.     14400   IN      MX      0       ASPMX.L.GOOGLE.COM.
$domain.     14400   IN      MX      5       ALT1.ASPMX.L.GOOGLE.COM.
$domain.     14400   IN      MX      5       ALT2.ASPMX.L.GOOGLE.COM.
$domain.     14400   IN      MX      10       ALT3.ASPMX.L.GOOGLE.COM.
EOF
	echo "Google MX records were added to /var/named/$domain.db , please review that file to see if everything is correct"
	systemctl reload named.service
fi
echo
