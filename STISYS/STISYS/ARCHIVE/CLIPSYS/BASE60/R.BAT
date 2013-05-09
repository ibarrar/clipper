Set PATH=%PATH%;D:\zip004\Clipper5\Bin;D:\zip004\BLINKER3;
Set LIB=%LIB%;D:\zip004\Clipper5\Lib;
Set INCLUDE=%INCLUDE%;D:\zip004\Clipper5\Include;
rmake BASE60 %1 %2 >err
type err
pause