#! /bin/bash
# Wanna install hadoop pseudo distributed mode?
# they you are at right place
################################################
# Author: Shalu Jain
# Date	: 26-Apr-2019
###############################################

check_availibility() {	
	op=`which $1`
	out=`echo $?`
	if [ $out -eq 0 ];then
		echo "$1 is available"
	else
		echo "looks like $1 is not availale, pls install it first then TRY AGAIN!"
		echo "exiting for now"
		exit ;
	fi
}

check_dir() {
	if [ -d $1 ]; then
		echo "Bingo! got the directory"
	else
		echo "looks like you entered wrong path"
		exit
	fi
}

ren_if_avail() {
	if [ -f $1 -o -d $1 ]; then
		echo "$1 exists"
		file_name=`echo $1|rev|cut -d"/" -f1|rev`
		echo "taking back up"
		new_name=$file_name"_backup_"`date '+%s'`
		backup_dir=~/hadoop_installation_backup
		mkdir -p $backup_dir
		new_name=$backup_dir'/'$new_name
		mv $1 $new_name
	fi
}

copy_if_avail() {
	if [ -f $1 ]; then
		echo "$1 exists"
		file_name=`echo $1|rev|cut -d"/" -f1|rev`
		echo "taking back up"
		new_name=$file_name"_backup_"`date '+%s'`
		backup_dir=~/hadoop_installation_backup
		mkdir -p $backup_dir
		new_name=$backup_dir'/'$new_name
		cp $1 $new_name
	fi
}


echo "Preparing system for Hadoop"
echo 

# Checking Java in the system
echo "Checking Java"
check_availibility java
JAVA_VER=`java -version 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
comp=`awk 'BEGIN{if ('$JAVA_VER'>'1.7') exit 1}'`
op=`echo $?`
echo $comp
if [ $op -eq 1 ];then
	echo "Java is good"
	echo "Current Java version is $JAVA_VER"
else
	echo "Whoops! Java version is less than 1.8"
	echo "Please update your Java and come back"
	echo "See you soon!"
	exit
fi


# Checking ssh
check_availibility ssh
echo "Gearing up for passwordless access"
echo "respond whenever it is required"
#clear
#sleep 1
# checking availability of ~/.ssh/id_rsa.pub
id_rsa=~/.ssh/id_rsa.pub
ren_if_avail $id_rsa
#if [ -f $id_rsa ];then
#	rm $id_rsa
#fi
#`yes y|echo -e "\n"|ssh-keygen -t rsa -P ""`
ssh-keygen -t rsa -P "" #-f $id_rsa`
cat ~/.ssh/id_rsa.pub>>~/.ssh/authorized_keys
echo "SSH setup completed"


# Installing hadoop
read -p "Where is your hadoop tar file?\n make sure you enter correct path(path is case sensitive)" spath
check_dir $spath
echo "available hadoop files are"
hadoop_tar_file=`ls $spath|grep -i "hadoop"|grep "tar.gz"`
spath=$spath"/"$hadoop_tar_file

tdir_name=`echo $spath|rev|cut -d"/" -f1|rev|cut -d"." -f1-3`
#echo $tdir_name

#read -p "Enter target directory with complete path:" tdir
#check_dir $tdir
tdir=~/
# check if target hadoop directory name is available(here it is Hadoop Home directory)
tpath=$tdir'/'$tdir_name
ren_if_avail $tpath
#echo $tpath

`tar xvf $spath --directory $tdir`
#hdp_home=`ls|grep -i hadoop`
# mv $spath $tpath

`ln -s $tpath ~/Desktop/hadoop`
# taking back up of .bashrc
cp ~/.bashrc ~/.bashrc_bkp

# adding Environment variables to .bashrc

# Java related path
jvm=/usr/lib/jvm
java_dir=`ll /usr/lib/jvm|grep -e '^d' | grep java|rev|cut -d' ' -f1|rev`
java_home=$jvm'/'$java_dir
#java_home=`echo $JAVA_HOME|cut -d"/" -f1-`
`echo "export JAVA_HOME=$java_home" >> ~/.bashrc`
`echo 'export PATH=$PATH:$JAVA_HOMEbin' >> ~/.bashrc`

# Hadoop related path
hadoop_home=$tpath
`echo "export HADOOP_HOME=$tpath" >> ~/.bashrc`
`echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc`
`echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc`
`echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc`
`echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' >> ~/.bashrc`
`echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc`
`echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> ~/.bashrc`
`echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"' >> ~/.bashrc`

# Apply changes in current running system
bashrc=~/.bashrc
source $bashrc


# Congfigure hadoop-env.sh
`echo "export JAVA_HOME=$java_home" >> $tpath/etc/hadoop/hadoop-env.sh`

config_dir=$tpath/etc/hadoop
hadoop_pseudo_cntl=~/hadoop_pseudo_install
# Configure mapred-site.xml
config_file=mapred-site.xml
# if mapred-site.cml is not available then copy from mapred-site.xml.template
config_file_path=$config_dir'/'$config_file
if [ -f $config_file_path ];then
	copy_if_avail $config_file_path
else
	cp $config_dir/mapred-site.xml.template $config_file_path
fi
	
sed "/<configuration>/r $hadoop_pseudo_cntl/$config_file" $config_file_path > temp
mv temp $config_file_path

# Configure core-site.xml
config_file=core-site.xml
config_file_path=$config_dir'/'$config_file
copy_if_avail $config_file_path
sed "/<configuration>/r $hadoop_pseudo_cntl/$config_file" $config_file_path > temp
mv temp $config_file_path


# Configure hdfs-site.xml

mkdir -p ~/hdfs/namenode
mkdir -p ~/hdfs/datanode

namenode=~/hdfs/namenode
datanode=~/hdfs/datanode

config_file=hdfs-site.xml
config_file_path=$config_dir'/'$config_file
copy_if_avail $config_file_path
sed "/<configuration>/r $hadoop_pseudo_cntl/$config_file" $config_file_path > temp
mv temp $config_file_path

#replace namenode and data node in the target file
sed -i "s:namenode_dir:$namenode:g; s:datanode_dir:$datanode:g" $config_file_path
#mv temp $config_file_path
#sed -i 's/datanode_dir/$datanode/g' $config_file_path

# Configure yarn-site.xml
config_file=yarn-site.xml
config_file_path=$config_dir'/'$config_file
copy_if_avail $config_file_path
sed "/<configuration>/r $hadoop_pseudo_cntl/$config_file" $config_file_path > temp
mv temp $config_file_path

# format hadoop name node
hadoop namenode -format # 2>&1 > format_log
#grep "successfully" format_log
#op=`echo $?`
#if [ $op -ne 0 ]; then
#	echo "Something is worng"
#	echo "namenode format failed"
#	exit
#else
#	echo "Namenode successfully formatted"
#fi


#start daemonons
start-dfs.sh
start-yarn.sh

#display hadoop daemons
jps


