# The_Backrooms
Assembly x86 Final Project.






![homescr](https://github.com/BiliSando/The_Backrooms/assets/121094257/30c35d7c-6e62-45a2-ac7f-f0749987ce6e)

![modes](https://github.com/BiliSando/The_Backrooms/assets/121094257/77028241-3893-4f7b-8fd2-eab7fc89eca6)

![ready](https://github.com/BiliSando/The_Backrooms/assets/121094257/015ea93d-0970-43b8-a76c-707fdc4c692d)

![options](https://github.com/BiliSando/The_Backrooms/assets/121094257/b30ab436-5935-4480-bc7f-dd554dccb2d5)

## Install

- Install [TASM](https://shreyasjejurkar.com/2017/03/27/how-to-install-and-configure-tasm-on-windows-7810/)
and put it under C:\

- Install [DOSBox](https://www.dosbox.com/download.php?main=1)
- Clone this repository to C:\tasm\bin\
- Open up DOSBox and run the game using this commands
```
 mount c: c:\
 c:
 cd tasm
 cd bin 
 tasm /zi Backrooms.asm
 tlink /v Backrooms.obj
 Backrooms
 
 ``` 
