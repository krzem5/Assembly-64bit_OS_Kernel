import os
import ntpath
import subprocess



if (ntpath.exists("build")):
	os.system("rmdir /s /q build")
os.mkdir("build")



if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","src\\installer\\asm\\ientry.asm","-f","elf","-o","build\\ientry.o"]).returncode==0 and subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","src\\installer\\asm\\paging.asm","-f","elf","-o","build\\paging.o"]).returncode==0):
	os.mkdir("build\\installer")
	k_fl=[]
	for r,_,fl in os.walk("src\\installer"):
		for f in fl:
			if (f[-2:]==".c" ):
				if (subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\gcc.exe","-m32","-Wall","-Werror","-fpic","-ffreestanding","-fno-stack-protector","-nostdinc","-nostdlib","-c",ntpath.join(r,f),"-o",f"build\\installer\\{f[:-2]}.o","-Isrc\\installer\\include"]).returncode!=0 or subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\strip.exe","-R",".rdata$zzz","--keep-file-symbols","--strip-debug","--strip-unneeded","--discard-locals",f"build\\installer\\{f[:-2]}.o"]).returncode!=0):
					quit()
				k_fl+=[f"build\\installer\\{f[:-2]}.o"]
	if (subprocess.run(["C:\\ProgramFiles\\Cygwin\\bin\\ld.exe","-melf_i386","-o","build\\installer.bin","-T","linker.ld","--oformat","binary","build\\ientry.o"]+k_fl).returncode==0):
		with open("build\\installer.bin","rb") as bf:
			kln=len(bf.read())
		with open("build\\_tmp_bl.asm","w") as wf,open("src\\installer\\asm\\bootloader.asm","r") as rf:
				wf.write(f"%define __KERNEL_SZ__ {kln}\n%line 0 src\\installer\\asm\\bootloader.asm\n")
				wf.write(rf.read())
		if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","build\\_tmp_bl.asm","-f","bin","-o","build\\bootloader.bin"]).returncode==0):
			with open("build\\bootloader.bin","rb") as bf:
				bln=len(bf.read())
			if (bln%512!=0):
				with open("build\\bootloader.bin","ab") as bf:
					bf.write(bytes((0,)*(512-bln%512)))
				bln+=512-bln%512
			with open("build\\_tmp_bli.asm","w") as wf,open("src\\installer\\asm\\bootloader_init.asm","r") as rf:
				wf.write(f"%define __BOOTLOADER_SZ__ {bln}\n%line 0 src\\installer\\asm\\bootloader_init.asm\n")
				wf.write(rf.read())
			if (subprocess.run(["C:\\Program Files\\NASM\\nasm.exe","build\\_tmp_bli.asm","-f","bin","-o","build\\bootloader_init.bin"]).returncode==0):
				with open("build\\bootloader_init.bin","rb") as bif,open("build\\bootloader.bin","rb") as bf,open("build\\installer.bin","rb") as kf,open("build\\os.bin","wb") as wf:
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
					if (subprocess.run(["qemu-img","create","-f","qcow2","build\\hdd.qcow2","5G"]).returncode==0):
						os.system("cls")
						subprocess.run(["C:\\Program Files\\qemu\\qemu-system-i386","-hda","build\\hdd.qcow2","-boot","d","-cdrom","build\\os.iso","-m","2G"])
