#!/bin/bash
 
n=$1
x=`echo $(( ( RANDOM % 2 )  + 1 ))`
t=`echo $(( ( RANDOM % 60 )  ))`
f=`echo $(( ( RANDOM % 2 ) + 1 ))`
 
for ((i=1; i <= $n ; i++))
do
    #Successful su sessions
    for u in `grep bash /etc/passwd | grep home | awk -F ":" '{ print $1}' | shuf`
    do
       for (( c=1; c <= $x; c++ ))
       do
       su -c "echo Hello World from $u" $u
       sleep $t
       t=`echo $(( ( RANDOM % 60 )  ))`
    done
    x=`echo $(( ( RANDOM % 2 )  + 1 ))`
 
    #Failed sudo sessions
    for ((l=1 ; l <= $f ; l++ ))
    do
       bu=`grep bash /etc/passwd | grep home | awk -F ":" '{ print $1}' | shuf | head -n 1`
       su - $bu -c "echo password | sudo -S echo 'Hello World'"
       sleep $t
       t=`echo $(( ( RANDOM % 30 )  ))`
    done
   f=`echo $(( ( RANDOM % 2 ) + 1 ))`
  done
done
