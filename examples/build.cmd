cd bunnies

call nme build flash
call nme build flash -Dnoscale
call nme build flash -Dnotransform
call nme build html5
call nme build html5 -Dnotransform
call nme build windows
call nme build windows -Dnotransform
call nme build windows -Dthread

cd ../char_with_sword

call nme build flash
call nme build html5
call nme build windows

cd ../massive_rotation

call nme build flash
call nme build flash -Dnotransform
call nme build html5
call nme build html5 -Dnotransform
call nme build windows
call nme build windows -Dnotransform
call nme build windows -Dthread
cd ..

pause