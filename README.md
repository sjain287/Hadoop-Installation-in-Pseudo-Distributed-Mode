# Hadoop-Installation in Pseudo Distributed Mode
This is for Hadoop Installation in Pseudo Distributed mode

ReadMe()
  if ReadMeFirst = true;
    follow steps;
    installation=success
  else
    ReadMe()
    
ReadMe:
1. Place the folder in Home directory
2. While generating public key keep the key name 
  a. Press 'enter' i.e just keep the default name and destination folder ~/.ssh/id_rsa.pub
  b. Type Yes: when asks for overwrite
3.Type complete directory name of Hadoop source tar file corretly (this program doen't work with typos)
4. While formatting namenode, enter 'yes' to format it.
5. MOST IMPORTANT THING: run scipt in the following way 
    $. ./pseudo.sh (dot space dot slash pseudo dot sh)
