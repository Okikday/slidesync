@echo off
echo [1/3] Removing pdfrx WASM modules...
call dart run pdfrx:remove_wasm_modules

echo [2/3] Cleaning project...
call flutter clean

echo [3/3] Building Apk 
call flutter build apk --release --obfuscate --split-debug-info=build/symbols --tree-shake-icons

echo Build complete!
pause