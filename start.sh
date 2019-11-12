#!/bin/sh
EULA='true'
ONLINE='true'
HOST='0.0.0.0'
PORT='25565'
NAME='Spigot'

# Download a url to a file
# $1 url
# $2 output file
# $3 boolean replace existing file
download() {
	if [ "$3" ] || [ ! -f "$2" ]; then
		echo "downloading $1 to $2"
		curl "$1" -o "$2"
	else 
		echo "-skipping $2 already exists"
	fi
}

# Read a file or default value
# $1 file
# $2 default if no file
cat_def() {
	if [ -f "$1" ]; then
		func_result=`cat $1`
	else
		func_result="$2"
	fi
}

# Download a plugin
# $1 job
# $2 artifact
# $3 file name
plugin() {
	job="$1"
	name="$2"
	ext="jar"
	proxy "$job" "$name" "$ext"
	latest=$(curl "$func_result")
	cat_def "plugins/$3.txt"
	current="$func_result"
	if [ "$latest" != "$current" ]; then
		download "$latest" "plugins/$3.jar" 1
		echo "$latest" | tee "plugins/$3.txt"
	else 
		echo "-skipping $2 as up to date"
	fi
}

# Proxy for downloading
proxy() {
	func_result="https://empcraft.com/download/index-dev.php?url=$1&name=$2&ext=$3"
}


# Server
server_jar="paper.jar";
server_url=`cat paper.txt`
download "$server_url" "$server_jar"


# PlotSquared
plugin "https://ci.athion.net/job/PlotSquared-Releases/lastSuccessfulBuild/artifact/target/" "PlotSquared-Bukkit" "PlotSquared"

# FAWE
plugin "https://ci.athion.net/view/Everything/job/FastAsyncWorldEdit-pipeline/lastSuccessfulBuild/artifact/worldedit-bukkit/build/libs/" "FastAsyncWorldEdit" "FastAsyncWorldEdit"
plugin "https://ci.athion.net/view/Everything/job/FastAsyncVoxelSniper-flattening/lastSuccessfulBuild/artifact/build/libs/" "FastAsyncVoxelSniper" "FastAsyncVoxelSniper"

# Run the server
java -Xms1G -Xmx1G -XX:+UseConcMarkSweepGC -jar -Dcom.mojang.eula.agree="$EULA" paper.jar --online-mode $ONLINE --host $HOST --port $PORT
