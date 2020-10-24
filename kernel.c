void kmain(){
	// const short color=0x0f00;
	// const char* str="Hello cpp world!";
	char* vga=(char*)0xb8000;
	*vga='X';
	// for (int i=0;i<16;i++){
	// 	vga[i+80]=color|str[i];
	// }
}
