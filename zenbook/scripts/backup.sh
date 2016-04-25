#!/bin/bash

function backup {
	echo $1

	# TODO: Check path
	local bucket=dixet-stores-backups-nti7papu9gcu
	local name=`basename $1`
	local uniq=`date +%s`

	#tar cvf - $1 | gzip -9 | aws s3 cp s3://dixet-stores-backups-nti7papu9gcu --region eu-central-1
	cd $1 && cd ..
	tar cv $name | gzip -9 | aws s3 cp - s3://$bucket/$name-$uniq.gz.tar --region eu-central-1
}

backup ~/.config

backup ~/Documents

backup ~/Pictures
