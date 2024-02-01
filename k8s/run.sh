#!/bin/bash

ldconfig

echo "dyn lib path: $LD_LIBRARY_PATH"
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export LD_LIBRARY_PATH

IP=$(hostname -I | xargs) # removes whitespace

if [[ -n "$MODE" ]] && [[ "$MODE" == "master" ]]; then
  echo "Starting as master on ${IP}:${PORT} with fail param ${FAIL_PARAM}..."
  # valgrind --leak-check=full \
  #        --show-leak-kinds=all \
  #        --track-origins=yes \
  #        --verbose \
  #        --log-file=valgrind-out.txt \
  #        ./src/master/master "${IP}" "${PORT}" "${FAIL_PARAM}"
  ./src/master/master "${IP}" "${PORT}" "${FAIL_PARAM}"
elif [[ "$MODE" == "proxy" ]]; then
  echo "Starting as proxy on ${IP}:${PORT}..."
  ./src/proxy/proxy "${IP}" "${PORT}"
else
  echo "Starting as worker on ${IP}:${PORT} with fail param ${FAIL_PARAM}..."
    # valgrind --leak-check=full \
    #      --show-leak-kinds=all \
    #      --track-origins=yes \
    #      --verbose \
    #      --log-file=valgrind-out.txt \
    #      ./src/worker/worker "${IP}" "${PORT}" "${FAIL_PARAM}"
  ./src/worker/worker "${IP}" "${PORT}" "${FAIL_PARAM}"
fi
