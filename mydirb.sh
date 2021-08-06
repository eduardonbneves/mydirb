#!/bin/bash
#wordlist="admin robots.txt sitemap.xml phpmyadmin wp-admin index.php"

url=$1

location=$(curl -s --head $url | grep Location | awk -F ' ' '{print $2}')

if [[ $location != "" ]]; then

	echo "Please, retry using URL $location"
	exit

fi

count_slash=$(echo $url | grep -o / | wc -l)

if [ $count_slash -le 3 ]; then
	new_url=$(echo $url | awk -F "/" '{print $1"//"$2$3"/"}')
	url=$new_url
fi

echo "url -> "$url

for dir in $(cat wordlist.txt); do
	echo "Searching for "$url$dir
	status_code=$(curl -s -o /dev/null -w '%{http_code}' $url$dir)
	if [ $status_code == "200" ]; then
		echo "$(tput setaf 2)FOUND -> "$url$dir$(tput sgr 0)
		echo -e "\n"
	fi
	if [ $status_code == "301" ] || [ $status_code == "302" ] || [ $status_code == "303" ] || [ $status_code == "307" ] || [ $status_code == "308" ]; then
		echo "$status_code -> Redirecting $url$dir"
		location=$(curl -s --head $url$dir | grep Location | awk -F ' ' '{print $2}')
		echo "$(tput setaf 2)FOUND -> "$location$(tput sgr 0)
		echo -e "\n"
	fi
done