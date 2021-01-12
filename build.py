import ntpath
import os
import subprocess



if (ntpath.exists("build")):
	os.system("rmdir /s /q build")
os.mkdir("build")



os.mkdir("build\\asm")
a_fl=[]
for k in os.listdir("src\\asm"):
	if (k[-4:]==".asm" and k not in ["bootloader.asm","bootloader_init.asm"]):
		if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe",f"src\\asm\\{k}","-f","elf64","-Wall","-Werror","-o",f"build\\asm\\{k[:-4]}.o"]).returncode!=0):
			quit()
		a_fl+=[f"build\\asm\\{k[:-4]}.o"]
os.mkdir("build\\c")
k_fl=[]
for r,_,fl in os.walk("src"):
	for f in fl:
		if (f[-2:]==".c"):
			if (subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\gcc.exe","-mcmodel=large","-mno-red-zone","-mno-mmx","-mno-sse","-mno-sse2","-fno-common","-m64","-Wall","-Werror","-fpic","-ffreestanding","-fno-stack-protector","-nostdinc","-nostdlib","-c",ntpath.join(r,f),"-o",f"build\\c\\{ntpath.join(r,f)[4:-2].replace(chr(92),'/').replace('/','$')}.o","-Isrc\\include"]).returncode!=0 or subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\strip.exe","-R",".rdata$zzz","--keep-file-symbols","--strip-debug","--strip-unneeded","--discard-locals",f"build\\c\\{ntpath.join(r,f)[4:-2].replace(chr(92),'/').replace('/','$')}.o"]).returncode!=0):
				quit()
			k_fl+=[f"build\\c\\{ntpath.join(r,f)[4:-2].replace(chr(92),'/').replace('/','$')}.o"]
if (subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\ld.exe","-melf_x86_64","-o","build\\build.bin","-T","linker.ld","--oformat","binary"]+a_fl+k_fl).returncode==0):
	with open("build\\build.bin","rb") as bf:
		kln=len(bf.read())
	with open("build\\_tmp_bl.asm","w") as wf,open("src\\asm\\bootloader.asm","r") as rf:
			wf.write(f"%define __KERNEL_SZ__ {kln}\n%line 0 src\\asm\\bootloader.asm\n")
			wf.write(rf.read())
	if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","build\\_tmp_bl.asm","-f","bin","-Wall","-Werror","-o","build\\bootloader.bin"]).returncode==0):
		with open("build\\bootloader.bin","rb") as bf:
			bln=len(bf.read())
		if (bln%512!=0):
			with open("build\\bootloader.bin","ab") as bf:
				bf.write(bytes((0,)*(512-bln%512)))
			bln+=512-bln%512
		with open("build\\_tmp_bli.asm","w") as wf,open("src\\asm\\bootloader_init.asm","r") as rf:
			wf.write(f"%define __BOOTLOADER_SZ__ {bln}\n%line 0 src\\asm\\bootloader_init.asm\n")
			wf.write(rf.read())
		if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","build\\_tmp_bli.asm","-f","bin","-Wall","-Werror","-o","build\\bootloader_init.bin"]).returncode==0):
			with open("build\\bootloader_init.bin","rb") as bif,open("build\\bootloader.bin","rb") as bf,open("build\\build.bin","rb") as kf,open("build\\os.bin","wb") as wf:
				wf.write(bif.read())
				wf.write(bf.read())
				wf.write(kf.read())
			os.mkdir("build\\iso")
			if (subprocess.run(["dd","if=/dev/zero","of=build\\iso\\os.img","bs=1024","count=1440"]).returncode==0 and subprocess.run(["dd","if=build\\os.bin","of=build\\iso\\os.img","seek=0","conv=notrunc"]).returncode==0 and subprocess.run(["genisoimage","-V","Krzem","-input-charset","iso8859-1","-o","build\\os.iso","-b","os.img","-hide","os.img","build\\iso"]).returncode==0):
				dl=[]
				for r,sdl,fl in os.walk("build"):
					for f in fl:
						f=ntpath.join(r,f)
						if (f!="build\\os.iso"):
							os.remove(f)
					if (r=="build"):
						dl+=sdl
				for k in dl:
					os.rmdir(f"build\\{k}")
				if (subprocess.run(["qemu-img","create","-f","qcow2","build\\hdd.qcow2","10G"]).returncode==0):
					os.system("cls")
					subprocess.run(["C:\\Program Files\\qemu\\qemu-system-x86_64","-hda","build\\hdd.qcow2","-boot","d","-cdrom","build\\os.iso","-m","16G","-net","none"])
