echo hello world
if [[ -n $1 ]]; then
        name=$1
else
        read -p 'Enter your name: ' name
fi

echo "$name"
thing=$(uname -a)
things=$(uname)
echo "hello $name"
echo "your pc is $things"
echo "$thing"

for loo in "$@"; do
        echo "thing is  $loo"
done
