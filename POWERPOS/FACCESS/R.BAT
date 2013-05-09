rmake r.rmk %1 %2 >err
type err
if errorlevel 1 goto stop
copy faccess.lib .\source
copy faccess.lib \powerpos\lib
:stop
