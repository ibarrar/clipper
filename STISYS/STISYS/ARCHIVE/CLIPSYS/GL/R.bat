Set PATH=%PATH%;D:\zip004\Clipper5\Bin;D:\zip004\Blinker3;
Set LIB=%LIB%;D:\zip004\Clipper5\Lib;D:\zip004\TC\LIB;
Set INCLUDE=%INCLUDE%;D:\zip004\Clipper5\Include;
rmake GL /B /W %1 %2 >err
type err
pause