#!/bin/bash
 
n=$1
x=`echo $(( ( RANDOM % 10 )  + 1 ))`
t=`echo $(( ( RANDOM % 3 )  ))`
f=`echo $(( ( RANDOM % 5 ) + 1 ))`
 
for ((i=1; i <= $n ; i++))
do
    #Successful su sessions
    for u in `grep bash /etc/passwd | grep home | awk -F ":" '{ print $1}' | shuf`
    do
       for (( c=1; c <= $x; c++ ))
       do
       su -c "echo Hello World from $u" $u
       sleep $t
       t=`echo $(( ( RANDOM % 5 )  ))`
    done
    x=`echo $(( ( RANDOM % 10 )  + 1 ))`
 
    #Failed sudo sessions
    for ((l=1 ; l <= $f ; l++ ))
    do
       su - $u -c "echo password | sudo -S echo 'Hello World'"
       sleep $t
       t=`echo $(( ( RANDOM % 5 )  ))`
    done
   f=`echo $(( ( RANDOM % 3 ) + 1 ))`
  done
done
