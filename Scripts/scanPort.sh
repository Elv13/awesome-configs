for p in {1..65534}
do
  (echo >/dev/tcp/localhost/$p) >/dev/null 2>&1 && echo "$p open"
done
