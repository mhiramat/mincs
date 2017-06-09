echo 1 > events/signal/signal_generate/enable
echo '!stacktrace' > events/signal/signal_generate/trigger
echo 'stacktrace if sig == 11' > events/signal/signal_generate/trigger
echo '!traceoff' > events/signal/signal_deliver/trigger
echo 'traceoff if sig == 11' > events/signal/signal_deliver/trigger

echo 1 > tracing_on
echo > trace

