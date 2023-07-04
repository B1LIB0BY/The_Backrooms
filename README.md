# The_Backrooms
Assembly x86 Final Project.






![homescr](https://raw.githubusercontent.com/BiliSando/The_Backrooms/main/homescr.bmp)

![modes](https://raw.githubusercontent.com/BiliSando/The_Backrooms/main/modes.bmp)

![ready](https://raw.githubusercontent.com/BiliSando/The_Backrooms/main/ready.bmp)

![options](https://raw.githubusercontent.com/BiliSando/The_Backrooms/main/options.bmp)

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
