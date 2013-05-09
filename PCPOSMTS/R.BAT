Set PATH=%PATH%;D:\zip004\Clipper5\Bin;
Set LIB=%LIB%;D:\zip004\Clipper5\Lib;D:\zip004\TC\LIB;
Set INCLUDE=%INCLUDE%;D:\zip004\Clipper5\Include;
rmake pcposmts %1 %2 >err
type err
move pcposmts.exe .\test