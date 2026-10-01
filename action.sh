#!/system/bin/sh
# SystemUI JIT Crash Fix - manual action (KernelSU Next app -> Modules -> this module -> Execute)
echo "Compiling com.android.systemui with speed filter..."
cmd package compile -m speed -f com.android.systemui
echo "exit=$?"
echo "status now:"
dumpsys package com.android.systemui | grep -m 1 -o '\[status=[a-z-]*\]'
